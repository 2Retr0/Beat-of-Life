@tool
class_name CompositorEffectGaussianBlur extends CompositorEffect

const DOWNSAMPLE_SHADER := preload('./dual_kawase_downsample.glsl')
const UPSAMPLE_SHADER := preload('./dual_kawase_upsample.glsl')
const BLIT_SHADER := preload('./blit.glsl')
const MIX_SHADER := preload('./mix.glsl')

const MAX_CASCADES := 4
const CONTEXT := &'gaussian_blur'

class Pipeline:
	var shader : RID
	var pipeline : RID

	func _init(device : RenderingDevice, shader_file: RDShaderFile) -> void:
		_notification(NOTIFICATION_PREDELETE) # Free previous shader
		if not shader_file.is_connected(&'changed', _init):
			shader_file.changed.connect(_init.bind(device, shader_file))

		var shader_spirv: RDShaderSPIRV = shader_file.get_spirv()
		if shader_spirv.compile_error_compute != '':
			printerr(shader_spirv.compile_error_compute)
			return
		shader = device.shader_create_from_spirv(shader_spirv)
		pipeline = device.compute_pipeline_create(shader)

	func _notification(what):
		if what == NOTIFICATION_PREDELETE:
			# Freeing our shader will also free any dependents such as the pipeline!
			if shader.is_valid(): RenderingServer.free_rid(shader)

@export_range(0.0, 64.0, 0.01, 'or_greater', 'exp') var radius := 32.0 :
	set(value):
		radius = value
		num_cascades = floori(clampf(log(radius)/log(2.0) - 1.0, 0.0, MAX_CASCADES))
		offset = radius / (2.0**(num_cascades - 1)) * 0.5
		should_generate_parameters = true

@export var blend_cascades := true

var device: RenderingDevice
var pipelines : Dictionary
var linear_sampler: RID
var parameters : Array[Dictionary]
var should_generate_parameters: bool

var num_cascades : int :
	set(value):
		num_cascades = value
		parameters.resize(value + 1)
		should_generate_parameters = true

var offset : float :
	set(value):
		offset = value
		should_generate_parameters = true

var mix_factor : float :
	get:
		var x := clampf((offset - 2.0) / 2.0 if num_cascades > 0 else offset / 4.0, 0.0, 1.0)
		return x*x*(3.0 - 2.0*x)

# Called when this resource is constructed.
func _init() -> void:
	effect_callback_type = CompositorEffect.EFFECT_CALLBACK_TYPE_POST_TRANSPARENT
	RenderingServer.call_on_render_thread(_init_compute)


func _init_compute() -> void:
	device = RenderingServer.get_rendering_device()
	pipelines.downsample = Pipeline.new(device, DOWNSAMPLE_SHADER)
	pipelines.upsample = Pipeline.new(device, UPSAMPLE_SHADER)
	pipelines.blit = Pipeline.new(device, BLIT_SHADER)
	pipelines.mix = Pipeline.new(device, MIX_SHADER)

	var sampler_state := RDSamplerState.new()
	sampler_state.min_filter = RenderingDevice.SAMPLER_FILTER_LINEAR
	sampler_state.mag_filter = RenderingDevice.SAMPLER_FILTER_LINEAR
	linear_sampler = device.sampler_create(sampler_state)


# Called by the rendering thread every frame.
func _render_callback(p_effect_callback_type: int, render_data: RenderData) -> void:
	if not (device and p_effect_callback_type == effect_callback_type): return

	# Get our render scene buffers object, this gives us access to our render buffers.
	# Note that implementation differs per renderer hence the need for the cast.
	var render_scene_buffers : RenderSceneBuffersRD = render_data.get_render_scene_buffers()
	if not render_scene_buffers: return

	# Get our render size, this is the 3D render resolution!
	var dims := render_scene_buffers.get_internal_size()
	var dims_blit := Vector3i(ceili(dims.x/16.0), ceili(dims.y/16.0), 1)
	if dims.x == 0 and dims.y == 0: return

	var should_blend_cascades := num_cascades < 4 and (blend_cascades or num_cascades == 0)

	_create_texture(render_scene_buffers, CONTEXT, &'pong_base', (dims / 2.0).ceil())
	if should_blend_cascades:
		_create_texture(render_scene_buffers, CONTEXT, &'pong_blend', (dims / 2.0).ceil())
		_create_texture(render_scene_buffers, CONTEXT, &'blend', dims)

	# If the dimensions of the image or radius have changed, regenerate dispatch parameters.
	if should_generate_parameters:
		for i in range(num_cascades + 1):
			var dims_cascade : Vector2i = (dims / 2.0**i).ceil()
			var dims_block := (Vector3(dims_cascade.x, dims_cascade.y, 1) / 8.0).ceil()
			var push_constant : PackedByteArray
			push_constant.resize(16)
			push_constant.encode_u32(0, dims_cascade.x)
			push_constant.encode_u32(4, dims_cascade.y)
			parameters[i] = { &'block_dimensions' : dims_block, &'push_constant': push_constant }
		should_generate_parameters = false

	var uniform_sets : Dictionary
	var view_count := render_scene_buffers.get_view_count()
	for view in range(view_count):
		var color_image := render_scene_buffers.get_color_layer(view)
		var pong_base_image := render_scene_buffers.get_texture_slice(CONTEXT, &'pong_base', view, 0, 1, 1)

		# Create a uniform set, this will be cached, the cache will be cleared if our viewports configuration is changed.
		uniform_sets.base = [
			UniformSetCacheRD.get_cache(pipelines.downsample.shader, 0, [ _create_uniform_texture(0, color_image, linear_sampler), _create_uniform_texture(1, pong_base_image) ]),
			UniformSetCacheRD.get_cache(pipelines.downsample.shader, 0, [ _create_uniform_texture(0, pong_base_image, linear_sampler), _create_uniform_texture(1, color_image) ]),
		]

		if should_blend_cascades:
			var blend_image := render_scene_buffers.get_texture_slice(CONTEXT, &'blend', view, 0, 1, 1)
			var pong_blend_image := render_scene_buffers.get_texture_slice(CONTEXT, &'pong_blend', view, 0, 1, 1)

			uniform_sets.blit = UniformSetCacheRD.get_cache(pipelines.blit.shader, 0, [ _create_uniform_texture(0, color_image), _create_uniform_texture(1, blend_image) ])
			uniform_sets.blend = [
				UniformSetCacheRD.get_cache(pipelines.downsample.shader, 0, [ _create_uniform_texture(0, blend_image, linear_sampler), _create_uniform_texture(1, pong_blend_image) ]),
				UniformSetCacheRD.get_cache(pipelines.downsample.shader, 0, [ _create_uniform_texture(0, pong_blend_image, linear_sampler), _create_uniform_texture(1, blend_image) ]),
			]

#region Compute Pipeline Chain
		var compute_list := device.compute_list_begin()
		if should_blend_cascades:
			_dispatch_pipeline(compute_list, pipelines.blit, dims_blit, uniform_sets.blit)
			device.compute_list_add_barrier(compute_list)

		# --- DOWNSAMPLE STAGE ---
		for i in range(num_cascades + 1):
			var params := parameters[i]
			if i < num_cascades:
				params.push_constant.encode_float(8, offset)
				_dispatch_pipeline(compute_list, pipelines.downsample, (params.block_dimensions/2.0).ceil(), uniform_sets.base[i % 2], params.push_constant)
			if should_blend_cascades:
				params.push_constant.encode_float(8, offset*0.5)
				_dispatch_pipeline(compute_list, pipelines.downsample, (params.block_dimensions/2.0).ceil(), uniform_sets.blend[i % 2], params.push_constant)
			device.compute_list_add_barrier(compute_list)

		# --- UPSAMPLE STAGE ---
		for i in range(num_cascades, -1, -1):
			var params := parameters[i]
			if i < num_cascades:
				params.push_constant.encode_float(8, offset)
				_dispatch_pipeline(compute_list, pipelines.upsample, params.block_dimensions, uniform_sets.base[1 - i % 2], params.push_constant)
			if should_blend_cascades:
				params.push_constant.encode_float(8, offset*0.5)
				_dispatch_pipeline(compute_list, pipelines.upsample, params.block_dimensions, uniform_sets.blend[1 - i % 2], params.push_constant)
			device.compute_list_add_barrier(compute_list)

		if should_blend_cascades:
			var mix_push_constant : PackedByteArray
			mix_push_constant.resize(16)
			mix_push_constant.encode_float(0, mix_factor)
			_dispatch_pipeline(compute_list, pipelines.mix, dims_blit, uniform_sets.blit, mix_push_constant)
		device.compute_list_end()
#endregion


func _dispatch_pipeline(compute_list : int, pipeline : Pipeline, grid_size : Vector3i, uniform_set : RID, push_constant:=PackedByteArray()) -> void:
	device.compute_list_bind_compute_pipeline(compute_list, pipeline.pipeline)
	device.compute_list_bind_uniform_set(compute_list, uniform_set, 0)
	device.compute_list_set_push_constant(compute_list, push_constant, push_constant.size())
	device.compute_list_dispatch(compute_list, grid_size.x, grid_size.y, grid_size.z)


func _create_uniform_texture(binding : int, texture : RID, sampler:=RID()) -> RDUniform:
	var uniform := RDUniform.new()
	uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
	uniform.binding = binding
	if sampler.is_valid():
		uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_SAMPLER_WITH_TEXTURE
		uniform.add_id(sampler)
	uniform.add_id(texture)
	return uniform


## Creates a cached texture from the given parameters. Recreates texture if dimensions change.
func _create_texture(render_scene_buffers: RenderSceneBuffersRD, context: StringName, name: StringName, dims: Vector2i, format:=RenderingDevice.DATA_FORMAT_R16G16B16A16_SFLOAT, usage:=RenderingDevice.TEXTURE_USAGE_SAMPLING_BIT | RenderingDevice.TEXTURE_USAGE_STORAGE_BIT) -> void:
	if render_scene_buffers.has_texture(context, name):
		var texture_format := render_scene_buffers.get_texture_format(context, name)
		if texture_format.width == dims.x and texture_format.height == dims.y:
			return
		# This will clear all textures for this viewport under this context
		render_scene_buffers.clear_context(context)
	render_scene_buffers.create_texture(context, name, format, usage, RenderingDevice.TEXTURE_SAMPLES_1, dims, 1, 1, true)
	should_generate_parameters = true

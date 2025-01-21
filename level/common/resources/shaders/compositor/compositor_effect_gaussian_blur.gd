@tool
class_name CompositorEffectGaussianBlur extends CompositorEffect

const GAUSSIAN_BLUR_SHADER := preload('./gaussian_blur.glsl')

@export_range(0, 1) var strength := 1.0

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

var device : RenderingDevice
var pipeline : Pipeline
var rids : Dictionary

# Called when this resource is constructed.
func _init() -> void:
	effect_callback_type = CompositorEffect.EFFECT_CALLBACK_TYPE_POST_TRANSPARENT
	RenderingServer.call_on_render_thread(_init_compute)


func _init_compute() -> void:
	device = RenderingServer.get_rendering_device()
	pipeline = Pipeline.new(device, GAUSSIAN_BLUR_SHADER)


# Called by the rendering thread every frame.
func _render_callback(p_effect_callback_type: int, render_data: RenderData) -> void:
	if not (device and p_effect_callback_type == effect_callback_type): return

	# Get our render scene buffers object, this gives us access to our render buffers.
	# Note that implementation differs per renderer hence the need for the cast.
	var render_scene_buffers : RenderSceneBuffersRD = render_data.get_render_scene_buffers()
	var render_scene_data : RenderSceneDataRD = render_data.get_render_scene_data()
	if not render_scene_buffers: return

	# Get our render size, this is the 3D render resolution!
	var dims := render_scene_buffers.get_internal_size()
	if dims.x == 0 and dims.y == 0: return

	# Push constant
	var push_constant := PackedFloat32Array([strength, 0.0, 0.0, 0.0]).to_byte_array()

	if render_scene_buffers.has_texture(&'gaussian_blur', &'transpose'):
		var format := render_scene_buffers.get_texture_format(&'gaussian_blur', &'transpose')
		if format.width != dims.x or format.height != dims.y:
			# This will clear all textures for this viewport under this context
			render_scene_buffers.clear_context(&'gaussian_blur')
			render_scene_buffers.create_texture(&'gaussian_blur', &'transpose', RenderingDevice.DATA_FORMAT_R16G16B16A16_SFLOAT, RenderingDevice.TEXTURE_USAGE_SAMPLING_BIT | RenderingDevice.TEXTURE_USAGE_STORAGE_BIT, RenderingDevice.TEXTURE_SAMPLES_1, Vector2i(dims.y, dims.x), 1, 1, true)
	else:
		render_scene_buffers.create_texture(&'gaussian_blur', &'transpose', RenderingDevice.DATA_FORMAT_R16G16B16A16_SFLOAT, RenderingDevice.TEXTURE_USAGE_SAMPLING_BIT | RenderingDevice.TEXTURE_USAGE_STORAGE_BIT, RenderingDevice.TEXTURE_SAMPLES_1, Vector2i(dims.y, dims.x), 1, 1, true)

	var view_count := render_scene_buffers.get_view_count()
	for view in range(view_count):
		var color_image := render_scene_buffers.get_color_layer(view)
		var transposed_image := render_scene_buffers.get_texture_slice(&'gaussian_blur', &'transpose', view, 0, 1, 1)

		# Create a uniform set, this will be cached, the cache will be cleared if our viewports configuration is changed.
		var uniform_set := UniformSetCacheRD.get_cache(pipeline.shader, 0, [ _create_uniform_texture(0, color_image) ])
		var uniform_set_transposed := UniformSetCacheRD.get_cache(pipeline.shader, 1, [ _create_uniform_texture(0, transposed_image) ])

		var compute_list := device.compute_list_begin()
		_dispatch_pipeline(compute_list, pipeline, Vector3i(ceili(dims.x / 128.0), dims.y, 1), [uniform_set, uniform_set_transposed], push_constant)
		_dispatch_pipeline(compute_list, pipeline, Vector3i(ceili(dims.y / 128.0), dims.x, 1), [uniform_set_transposed, uniform_set], push_constant)
		device.compute_list_end()


func _dispatch_pipeline(compute_list : int, pipeline : Pipeline, grid_size : Vector3i, uniform_sets : Array[RID], push_constant:=PackedByteArray()) -> void:
	device.compute_list_bind_compute_pipeline(compute_list, pipeline.pipeline)
	for i in range(len(uniform_sets)):
		device.compute_list_bind_uniform_set(compute_list, uniform_sets[i], i)
	device.compute_list_set_push_constant(compute_list, push_constant, push_constant.size())
	device.compute_list_dispatch(compute_list, grid_size.x, grid_size.y, grid_size.z)


func _create_uniform_texture(binding : int, texture : RID) -> RDUniform:
	var uniform := RDUniform.new()
	uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
	uniform.binding = binding
	uniform.add_id(texture)
	return uniform

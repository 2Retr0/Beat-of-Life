extends Node

const DEFAULT_PATH := 'user://settings.cfg'

## Holds settings used by game. Contains default values on instantiation.
class Settings extends Object:
	const MISC_GROUP_NAME := 'general'
	
	# NOTE: Export annotations describe the layout of the settings. I think this
	#       is an easy way to hardcode the configuration schema.
	@export_category('gameplay')
	
	@export_category('sound')
	@export var this_should_be_in_general_group := false
	
	@export_category('visual')
	@export_group('display')
	@export var fullscreen : bool = ProjectSettings.get_setting(&'display/window/size/mode') == DisplayServer.WINDOW_MODE_FULLSCREEN :
		set(value):
			fullscreen = value
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if value else DisplayServer.WINDOW_MODE_WINDOWED)
	@export var enable_vsync : bool = ProjectSettings.get_setting(&'display/window/vsync/vsync_mode') == DisplayServer.VSYNC_ENABLED :
		set(value):
			enable_vsync = value
			DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if value else DisplayServer.VSYNC_DISABLED)
	
	@export_group('graphics')
	
	@export_category('controls')
	
	@export_category('accessibility')

	## Returns a triply-nested dictionary (category > group > value) of all
	## exported properties.
	static func serialize(settings : Settings) -> Dictionary:
		var property_list := settings.get_property_list()
		var properties := {}
		var category := {&'name': '', &'data': {}} # Pair of name and dict
		var group := {&'name': '', &'data': {}}    # Pair of name and dict
		
		for property in property_list:
			if property.name == 'Built-in script': continue # FIXME: hack
			
			if property.usage & PROPERTY_USAGE_CATEGORY:
				category.data[group.name] = group.data
				if not category.name.is_empty(): properties[category.name] = category.data
				group = {&'name': MISC_GROUP_NAME, &'data': {}}
				category = {&'name': property.name, &'data': {group.name : group.data}}
				
			elif property.usage & PROPERTY_USAGE_GROUP:
				category.data[group.name] = group.data
				group = {&'name': property.name, &'data': {}}
				
			elif property.usage & PROPERTY_USAGE_SCRIPT_VARIABLE:
				group.data[property.name] = settings[property.name]
		return properties


	## Deserializes a dictionary representing a [Class]Setting[/Class] object.
	static func deserialize(properties : Dictionary) -> Settings:
		var settings := Settings.new()
		for section in properties.values(): \
		for group in section.values(): \
		for property_name in group:
			if property_name not in settings or typeof(settings[property_name]) != typeof(group[property_name]): 
				printerr('Encountered unexpected type in setting property!')
				return null
			settings[property_name] = group[property_name]
		return settings

var settings : Settings

func _init() -> void:
	if FileAccess.file_exists(DEFAULT_PATH):
		settings = load_saved_values()
	if not settings: # If config doesn't exist OR the saved config is corrupted.
		settings = load_default_values()
	print('Loaded Settings: %s' % str(Settings.serialize(settings)))


## Loads default settings and writes them into a new config file. 
static func load_default_values() -> Settings:
	# NOTE: The contents of this function could be swapped out to use something other than ConfigFile!
	var settings := Settings.new()
	var config_file := ConfigFile.new()
	var properties := Settings.serialize(settings)
	# Loop through dict serialized properties of settings
	for section_name in properties.keys():
		var section : Dictionary = properties[section_name]
		for group_name in section.keys():
			var group : Dictionary = section[group_name]
			for property_name in group:
				config_file.set_value('%s/%s' % [section_name, group_name], property_name, group[property_name])
	config_file.save(DEFAULT_PATH)
	return settings


## Loads saved settings from a config file. If the configuration is invalid, 
## settings will be [code]null[/code].
static func load_saved_values() -> Settings:
	# NOTE: The contents of this function could be swapped out to use something other than ConfigFile!
	var config_file := ConfigFile.new()
	if config_file.load(DEFAULT_PATH) != OK: return null
	
	var properties := {}
	# Parse each section of the config file into sections (categories) and groups.
	for section in config_file.get_sections():
		assert(len(section.split('/')) == 2)
		var section_name := section.split('/')[0]
		var group_name := section.split('/')[1]
		if section_name not in properties:
			properties[section_name] = {}
		properties[section_name][group_name] = {}
		
		for property_name in config_file.get_section_keys(section):
			properties[section_name][group_name][property_name] = config_file.get_value(section, property_name)
	return Settings.deserialize(properties)

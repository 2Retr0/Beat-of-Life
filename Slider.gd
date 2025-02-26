extends HSlider

@export
var bus_name: String
var bus_index: int

func _ready() -> void:
	# looks up bus by name and saves as index
	bus_index = AudioServer.get_bus_index(bus_name) 
	# updates when volume changes
	value_changed.connect(_on_value_changed)
	
	value = db_to_linear( # unsure what this does
		AudioServer.get_bus_volume_db(bus_index)
	)
	
func _on_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(
		bus_index, # acesses bus
		linear_to_db(value) # adjusts the volume
	)

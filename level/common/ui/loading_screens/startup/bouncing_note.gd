extends TextureRect

# Parameters
var ground_level = 400             # Y position of the ground
var bounce_time = 0.0              # Time elapsed since bounce started

# Bounce settings
var initial_amplitude = 200.0      # How high the bounce starts
var damping_factor = 7.0           # Controls decay rate
var frequency = 20.0               # Controls bounce speed

func _process(delta):
	bounce_time += delta
	var amplitude = initial_amplitude * exp(-damping_factor * bounce_time)
	var bounce_offset = amplitude * abs(sin(bounce_time * frequency))
	
	position.y = -bounce_offset

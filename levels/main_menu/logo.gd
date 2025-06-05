extends Node

const LETTER_DELAY := 0.15
const WORD_DELAY := 0.5

signal finished

var tween: Tween

var is_animating := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_logo_alpha(0.0)

func animate() -> void:
	is_animating = true
	$Background.visible = true

	tween = create_tween().set_parallel(true)
	var delay := 0.0
	for word: Control in [$Words/Beat, $Words/of]:
		for letter: Control in word.get_children():
			tween.tween_property(letter, ^'position:y', letter.position.y, 1.5).from(letter.position.y - letter.size.y/2.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC).set_delay(delay)
			tween.tween_property(letter, ^'self_modulate:a', 1.0, 0.5).from(0.0).set_ease(Tween.EASE_OUT).set_delay(delay)
			delay += LETTER_DELAY
		delay += WORD_DELAY

	delay -= LETTER_DELAY*2.0
	for letter: Control in $Words/Life.get_children():
		tween.tween_property(letter, ^'scale', Vector2.ONE, 0.5).from(Vector2.ONE*0.5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUINT).set_delay(delay)
		tween.tween_property(letter, ^'self_modulate:a', 1.0, 0.5).from(0.0).set_trans(Tween.TRANS_QUAD).set_delay(delay)

		var letter_origin := letter.position
		tween.tween_method(func(t: float):
			var theta := 2.0*PI*t*10.0
			letter.position = letter_origin + Vector2(sin(theta), sin(theta*0.8 + 0.5))*letter.size.y/27.0, 0.0, 1.0, 0.125).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_ELASTIC).set_delay(delay + 0.3)
		delay += LETTER_DELAY*1.85
	delay -= LETTER_DELAY*1.85 - 0.325

	tween.tween_property($Foreground, ^'color:a', 0.0, 8.0).from(1.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO).set_delay(delay)
	tween.tween_callback(func():
		is_animating = false
		finished.emit()
		$Background.visible = false).set_delay(delay)

func skip_animation() -> void:
	if not is_animating: return

	is_animating = false
	if tween:
		tween.custom_step(10.0)
		tween.kill()

	tween = create_tween()
	tween.tween_property($Foreground, ^'color:a', 0.0, 12.0).from(1.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	$Background.visible = false
	set_logo_alpha(1.0)
	finished.emit()

func set_logo_alpha(alpha: float) -> void:
	for word: Control in $Words.get_children():
		for letter: Control in word.get_children():
			letter.self_modulate.a = alpha

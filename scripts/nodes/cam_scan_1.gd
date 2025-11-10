extends Button

@export var hold_time_required := 1.5  # segundos necesarios
var hold_timer := 0.0
var is_holding := false

func _process(delta):
	if is_holding:
		hold_timer += delta
		$ProgressBar.value = (hold_timer / hold_time_required) * 100
		if hold_timer >= hold_time_required:
			is_holding = false
			hold_timer = 0.0
			_on_long_press()


func _on_button_up():
	is_holding = false
	hold_timer = 0.0
	$ProgressBar.hide()

func _on_long_press():
	print("¡Botón presionado el tiempo suficiente!")
	# Aquí pones lo que quieres que haga el botón


func _on_button_down() -> void:
	is_holding = true
	hold_timer = 0.0
	$ProgressBar.show()

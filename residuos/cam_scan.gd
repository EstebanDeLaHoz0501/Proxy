extends Button

@export var hold_time_required := 1.5  # segundos necesarios
var hold_timer := 0.0
var is_holding := false
var tooltype = 'SCANNER'
func _process(delta):
	if is_holding:
		hold_timer += delta
		get_parent().get_node("ProgressBar").value = (hold_timer / hold_time_required) * 100
		if hold_timer >= hold_time_required:
			is_holding = false
			hold_timer = 0.0
			_on_long_press()


func _on_button_up():
	is_holding = false
	hold_timer = 0.0
	get_parent().get_node("ProgressBar").hide()

func _on_long_press():
	
	if name == "CamScan1":
		get_parent().get_parent().get_parent().get_parent().get_parent().ejecutar_accion_final(1,tooltype)
	if name == "CamScan2":
		get_parent().get_parent().get_parent().get_parent().get_parent().ejecutar_accion_final(2,tooltype)
	if name == "CamScan3":
		get_parent().get_parent().get_parent().get_parent().get_parent().ejecutar_accion_final(3,tooltype)
	if name == "CamScan4":
		get_parent().get_parent().get_parent().get_parent().get_parent().ejecutar_accion_final(4,tooltype)
	if name == "CamScan5":
		get_parent().get_parent().get_parent().get_parent().get_parent().ejecutar_accion_final(5,tooltype)
	# Aquí pones lo que quieres que haga el botón


func _on_button_down() -> void:
	is_holding = true
	hold_timer = 0.0
	get_parent().get_node("ProgressBar").show()

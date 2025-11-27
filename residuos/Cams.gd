extends Control

#estos botones cambian drasticamente la escena, desechando la otra (siguiendo la logica de arriba)
#abierto a posibles cambios (poner todas las img como hijos y ocultarlas temporalmente)
func _on_button_back_1_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game/office.tscn")

func _on_button_back_2_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game/office.tscn")

func _on_button_back_3_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game/office.tscn")

func _on_button_back_4_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game/office.tscn")

func _on_button_back_5_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game/office.tscn")

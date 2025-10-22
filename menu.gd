extends Control


func _on_jugar_pressed() -> void:
	get_tree().change_scene_to_file("res://Registro.tscn")

func _on_settings_pressed() -> void:
	get_tree().change_scene_to_file("res://settings.tscn")

func _on_extras_pressed() -> void:
	get_tree().change_scene_to_file("res://extras.tscn")


func _on_close_pressed() -> void:
	get_tree().quit()

extends Control


func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game/nights.tscn")

func _on_settings_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/settings.tscn")

func _on_extras_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/extras.tscn")

func _on_close_pressed() -> void:
	get_tree().quit()

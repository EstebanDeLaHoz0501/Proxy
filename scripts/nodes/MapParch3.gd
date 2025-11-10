extends Node


func _on_volver_map_parch_3_pressed() -> void:
	get_tree().current_scene.get_node("MapParch3").hide()

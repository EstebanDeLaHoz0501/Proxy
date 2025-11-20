extends Node


func _on_volver_map_fw_pressed() -> void:
	get_tree().current_scene.get_node("MapFirewalls").hide()

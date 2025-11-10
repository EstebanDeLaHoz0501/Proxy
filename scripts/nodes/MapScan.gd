extends Node


func _on_volver_map_scan_pressed() -> void:
	get_tree().current_scene.get_node("MapScan").hide()

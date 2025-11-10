extends Node

var open = false

func _on_cerrar_map_2_pressed() -> void:
	if open == false:
		$AnimationPlayer.play("open")
		open = true
	else:
		$AnimationPlayer.play("close")
		open = false



func _on_cam_1_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game/Cams/Cam1.tscn")

func _on_cam_2_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game/Cams/Cam2.tscn")


func _on_cam_3_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game/Cams/Cam3.tscn")


func _on_cam_4_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game/Cams/Cam4.tscn")


func _on_cam_5_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game/Cams/Cam5.tscn")


func _on_scanner_pressed() -> void:
	get_parent().get_node("Control2").visible = true

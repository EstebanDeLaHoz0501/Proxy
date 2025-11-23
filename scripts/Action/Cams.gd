extends Control

var cam = null

func _on_cam_1_pressed() -> void:
	if cam != "Cam1":
		get_tree().change_scene_to_file("res://scenes/game/Cams/Cam1.tscn")
		cam = "Cam1"

func _on_cam_2_pressed() -> void:
	if cam != "Cam2":
		get_tree().change_scene_to_file("res://scenes/game/Cams/Cam2.tscn")
		cam = "Cam2"


func _on_cam_3_pressed() -> void:
	if cam != "Cam3":
		get_tree().change_scene_to_file("res://scenes/game/Cams/Cam3.tscn")
		cam = "Cam3"


func _on_cam_4_pressed() -> void:
	if cam != "Cam4":
		get_tree().change_scene_to_file("res://scenes/game/Cams/Cam4.tscn")
		cam = "Cam4"


func _on_cam_5_pressed() -> void:
	if cam != "Cam5":
		get_tree().change_scene_to_file("res://scenes/game/Cams/Cam5.tscn")
		cam = "Cam5"

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

extends Node
@export var next_scene_path: String 

func _on_button_pressed():
	change_scene()
	
func change_scene ():
	get_tree().change_scene_to_file("res://prueba.tscn")
	print("hola")

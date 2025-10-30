extends Control

@onready var n1 = $"VBoxContainer/nivel 1"

@onready var n2 = $"VBoxContainer/nivel 2"
@onready var n3 = $"VBoxContainer/nivel 3"
@onready var n4 = $"VBoxContainer/nivel 4"
@onready var n5 = $"VBoxContainer/nivel 5"
func _ready():
	n2.disabled = true
	n3.disabled = true
	n4.disabled = true
	n5.disabled = true
	if Proxyy and Proxyy.getJugadorActual():
		if(Proxyy.getJugadorActual().getNiveles().contains(Proxyy.getNiveles()[0])):
			n2.disabled = false
		elif (Proxyy.getJugadorActual().getNiveles().contains(Proxyy.getNiveles()[1])):
			n3.disabled = false
		elif (Proxyy.getJugadorActual().getNiveles().contains(Proxyy.getNiveles()[2])):
			n4.disabled = false
		elif (Proxyy.getJugadorActual().getNiveles().contains(Proxyy.getNiveles()[3])):
			n5.disabled = false

func _on_nivel_1_pressed() -> void:
	get_tree().change_scene_to_file("res://oficina.tscn")

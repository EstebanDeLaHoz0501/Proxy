extends Control

func obtenertexto() -> String:
	return $ColorRect/LineEdit.text
	
func _on_button_3_pressed() -> void:
	var e = obtenertexto()
	var jugador = Jugador.new(e)
	Proxyy.addJugadores(jugador)
	get_tree().change_scene_to_file("res://niveles.tscn")

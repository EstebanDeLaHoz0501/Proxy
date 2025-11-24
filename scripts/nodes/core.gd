extends Node
var open = false

func _on_button_pressed() -> void:
	get_parent().get_parent().get_node("corenew").visible = true

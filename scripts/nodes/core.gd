extends Node
var open = false

func _on_button_pressed() -> void:
	if open == false:
		$AnimationPlayer.play("open")
		open = true
	else:
		$AnimationPlayer.play("close")
		open = false

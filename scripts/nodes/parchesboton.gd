extends Button

func _gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			print("Clic izquierdo")
			get_parent().get_parent().get_parent()._on_parches_pressed()
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			print("Clic derecho")
			get_parent().get_parent().get_parent()._on_parches3_pressed()

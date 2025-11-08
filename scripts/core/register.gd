extends Control


# Esta función ya la tenías y está perfecta
func obtenertexto() -> String:
	# REVISA ESTA RUTA: 
	# Si "LineEdit" es hijo directo de "Control" (el nodo raíz de la escena),
	# la ruta debería ser solo: return $LineEdit.text
	return $colorReactCuadro/lineEditAntivirus.text 

# Esta es la función que vamos a cambiar


func _on_button_ok_pressed() -> void:
	
	# 1. Obtenemos el texto (¡Usando tu función!)
	var nombre_ingresado = obtenertexto()
	
	# 2. Preparamos los datos base para JSON
	# (Llamamos a los datos base desde el SaveManager global)
	var datos_nuevos = SAVEMANAGER.BASE_DATA.duplicate()
	datos_nuevos["nombre_jugador"] = nombre_ingresado
	datos_nuevos["noche_mas_alta"] = 1 # Empezamos en la noche 1
	
	# 3. Llamamos al SaveManager para crear el archivo JSON en el disco
	# (Asumimos que esta pantalla crea el Slot 1 por ahora)
	var exito = SAVEMANAGER.guardar_slot(1, datos_nuevos) 

# CRÍTICO: El cambio de escena SOLO ocurre si se guarda con ÉXITO.
	if exito:
		get_tree().change_scene_to_file("res://scenes/ui/menu.tscn")
	else:
# Muestra una alerta si falla el guardado
		print("ERROR FATAL: El guardado del archivo JSON falló. Revisar permisos de usuario.")
# ... (tus funciones anteriores)

# Esta función se ejecuta inmediatamente cuando se carga la escena
# En registro.gd

func _ready():
	# 1. Cargamos el slot 1
	var slot_data = SAVEMANAGER.cargar_slot(1)

		# 2. Comprobación Robusta: Si existe la clave y el nombre NO es el valor de fábrica "VACIO".
	if slot_data.has("nombre_jugador") and slot_data["nombre_jugador"] != "VACIO":
		# ¡El jugador existe! Anulamos la carga de esta escena y saltamos al menú.
		get_tree().change_scene_to_file.call_deferred("res://scenes/ui/menu.tscn")
	else:
		#No hay registro, mostramos la pantalla.
		pass

extends Control


@onready var n1_box = $VBoxContainer/night1
@onready var n2_box = $VBoxContainer/night2
@onready var n3_box = $VBoxContainer/night3
@onready var n4_box = $VBoxContainer/night4
@onready var n5_box = $VBoxContainer/night5

# Lista para iterar sobre ellos fácilmente (Noche 1, 2, 3, 4, 5)
var nights_botones: Array 

func _ready():
	# Inicializa la lista de botones.
	nights_botones = [n1_box, n2_box, n3_box, n4_box, n5_box]
	
	# Asumo que tu Autoload se llama 'GAMEMANAGER'
	# Lee la noche máxima permitida desde el global.
	var noche_maxima = GAMEMANAGER.noche_maxima_desbloqueada
	
	# El Nivel 1 siempre está disponible.
	
	# Iteramos desde la Noche 2 (índice 1) hasta la Noche 5 (índice 4).
	for i in range(1, nights_botones.size()):
		var nivel_actual = i + 1 # 2, 3, 4, 5
		var boton_night = nights_botones[i]
		
		if nivel_actual <= noche_maxima:
			# Si la noche actual es <= la máxima desbloqueada, activa el botón.
			boton_night.disabled = false
			boton_night.modulate = Color.WHITE # Color normal
		else:
			# Si no ha llegado a esa noche, desactiva el botón y lo atenúa.
			boton_night.disabled = true 
			boton_night.modulate = Color(0.3, 0.3, 0.3, 1.0) # Gris oscuro

func _on_regresar_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/menu.tscn")
	
	
func _on_night_1_pressed() -> void:
		# Asumo que tu Autoload global se llama GAMEMANAGER
	var game_manager = get_node("/root/GAMEMANAGER") 
	
	# --- PASO CRÍTICO 1: Cargar el Modelo ---
	# Llamamos a la función que SÓLO carga los datos, pero NO cambia la escena.
	game_manager.load_night_data(1) 
	
	# --- PASO CRÍTICO 2: Cambiar la Vista ---
	# Una vez que los datos están cargados globalmente, es SEGURO cambiar de escena.
	get_tree().change_scene_to_file("res://scenes/game/office.tscn")

extends Node
class_name GameManager
#----------------------------------------------------------------------------------
# Esta clase es un SINGLETON, y se convierte al ir a ajustes y darle en AUTOLOAD
#----------------------------------------------------------------------------------


# --- MODELO DE PROGRESO ---
# Definimos la var que almacena la noche más alta que ha desbloqueado el jugador.
var noche_maxima_desbloqueada: int = 1 

# --- MODELO DE ESTADO ACTUAL ---
# Definimos la var que almacena los DATOS de la noche que se está jugando AHORA
# Es la "Ficha"
var current_night_data: NightBase # Referencia a tu clase base de datos

# --- CONTROLADOR ---
# Esta función verifica desde el botón "night1", etc. si tenemos desbloqueada la noche
func start_night(night_number: int):
	# 1. Comprueba si el jugador tiene permiso para jugar esta noche
	if night_number > noche_maxima_desbloqueada:
		print("ERROR: night " + str(night_number) + " aún no está desbloqueado.")
		return # No hacemos nada

	# 2. Carga el archivo de REGLAS (.tres) de la noche seleccionada
	# Estas son las configuraciones individuales de cada night. Esto se hace con archivos .tres
	var path = "res://data/night_" + str(night_number) + ".tres"
	var loaded_data = load(path)
	
	if loaded_data is NightBase:
		current_night_data = loaded_data # Guardamos las reglas globalmente
		
		# 3. Carga la escena de la oficina (la Vista)
		get_tree().change_scene_to_file("res://scenes/game/office.tscn")
	else:
		print("ERROR: No se pudo cargar el archivo de reglas: " + path)
	

# Esta función la llamas desde la escena "Victoria"
func nivel_completado(noche_que_gano: int):
	if noche_que_gano >= noche_maxima_desbloqueada:
		noche_maxima_desbloqueada = noche_que_gano + 1
		print("¡Nivel desbloqueado! Noche máxima ahora es: " + str(noche_maxima_desbloqueada))
		
func load_night_data(night_number: int):
	# 1. Comprueba si el jugador tiene permiso para jugar esta noche (opcional)
	# if night_number > noche_maxima_desbloqueada: return 

	# 2. Carga el archivo de REGLAS (.tres) de la noche seleccionada
	var path = "res://data/night_" + str(night_number) + ".tres"
	var loaded_data = load(path)
	if loaded_data is NightBase:
		# 3. Almacena el MODELO de datos globalmente.
		self.current_night_data = loaded_data 
		print("Modelo de datos de Noche " + str(night_number) + " cargado con éxito.")
	else:
		print("ERROR: Falló al cargar archivo de reglas en GameManager: " + path)
	MapManager.spawn_malware_inicial()
# Tu función 'start_night' antigua ya no se necesita si usamos esta nueva.

@onready var MapManager = get_node("/root/MAPMANAGER") # Asumiendo que es un Autoload

var Ofice = null
func registrarEscena(scene):
	Ofice = scene
func TimeEventPopUp():
	if Ofice:
		Ofice.trigger_PopUp()
		Ofice.do = true
		

# En res://scripts/core/malware.gd
func trigger_game_over(malware):
	if(malware == 'Phishing'):
		get_tree().change_scene_to_file("res://scenes/GameOver/PhisingGM.tscn")
	elif(malware == 'Spyware'):
		get_tree().change_scene_to_file("res://scenes/GameOver/SpywareGM.tscn")
	elif(malware == 'PopUp'):
		get_tree().change_scene_to_file("res://scenes/GameOver/PopupGM.tscn")
	get_tree().paused = true 

#func _ready():
	# Asegúrate de que el mapa se cree primero
	#MapManager.crear_mapa_backend()
	#MapManager.spawn_malware_inicial() 
	 # ¡Soltamos a la bestia!
	# Llama a la función de spawn, que ahora vive en MapManager
	

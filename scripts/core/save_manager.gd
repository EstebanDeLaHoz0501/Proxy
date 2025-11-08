extends Node
class_name SaveManager

#----------------------------------------------------------------------------------
# Esta clase es un SINGLETON, y se convierte al ir a ajustes y darle en AUTOLOAD
#----------------------------------------------------------------------------------

# Se crean las variables de cada registro, el # de slot y donde se guardan
const SLOTS_MAX: int = 10
const SAVE_DIR: String = "user://" #Se guardan en .../Godot/app_userdata/PROXY_Game/, que son las capretas datas
const BASE_DATA = {
	"nombre_jugador": "VACIO",
	"noche_mas_alta": 0,
	"victorias_totales": 0,
	"datos_extras": {}
}

# Almacena los datos cargados de todos los slots, usamos Dictionary porque es lo mejor que se lleva con json
var slots_data: Array[Dictionary] = []

func guardar_slot(slot_index: int, data: Dictionary):
	var file_path = SAVE_DIR + "slot_" + str(slot_index) + ".json"
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	# Se crean el path de los partidas y se verifica por si hay un error que retorne falso
	if file == null:
		print("ERROR: No se pudo abrir el archivo para escribir.")
		return false
	# De lo contrario solo se guarda
	var json_string = JSON.stringify(data)
	file.store_string(json_string)
	
	return true

# 
func cargar_slot(slot_index: int) -> Dictionary:
	var file_path = SAVE_DIR + "slot_" + str(slot_index) + ".json"

	# Intenta abrir el archivo. Si no existe, file será 'null'.
	var file = FileAccess.open(file_path, FileAccess.READ)

	if file == null:
	# Si NO se puede abrir (porque no existe o falló la lectura), devuelve vacío.
		return {} 

	var content = file.get_as_text()
	var json_parse_result = JSON.parse_string(content)

	if json_parse_result is Dictionary:
		return json_parse_result
	else:
	# Si está corrupto o mal, devuelve vacío.
		return {}

class_name NodoRed
extends RefCounted

# Datos del Nodo
var id_numero: int 
var nombre: String
var tipo: String # "Gateway", "Server", "Core"
var nivel_infeccion: int = 0 # 0=Limpio, 1=Virus, 2=Tomando, 3=Tomado (Controlado)
var malware_presente: MalwareBase = null # ¿Qué bicho está aquí?
var distancia_al_nucleo: int = -1  # <--- ESTA ES LA QUE CAUSA EL ERROR
# --- BANDERAS DE CLASIFICACIÓN (Lo que falta) ---
var es_gateway: bool = false      # Para saber dónde spawnea el malware
var es_nucleo: bool = false       # Para saber cuándo es Game Over
var es_objetivo_worm: bool = false  # Para otros malwares (si aplica)

# CONEXIONES (El Grafo): Lista de vecinos a los que se puede mover el virus
var vecinos: Array[NodoRed] = [] 

func _init(num_id: int, nombre_nodo: String, tipo_nodo: String):
	# Asegúrate de que los tres parámetros estén definidos aquí
	id_numero = num_id
	nombre = nombre_nodo
	# Guardamos el tipo que acabamos de recibir
	tipo = tipo_nodo 
	
	nivel_infeccion = 0 

# Lógica de Infección
func aumentar_infeccion(cantidad: float):
	# Aquí subimos una barra interna float, y si pasa un umbral, sube el nivel entero
	# Por simplicidad ahora, digamos que recibimos progreso
	pass

func conectar_con(otro_nodo: NodoRed):
	if not vecinos.has(otro_nodo):
		vecinos.append(otro_nodo)
		# Si la conexión es doble vía (pueden ir y venir):
		otro_nodo.vecinos.append(self)
		
func reparar(otro_nodo: NodoRed):
	if not vecinos.has(otro_nodo):
		vecinos.append(otro_nodo)
		
func bloquear_vecino(otro_nodo: NodoRed):
	for nodo in self.vecinos:
		print(nodo.id_numero)
	self.vecinos.erase(otro_nodo)
	for nodo in self.vecinos:
		print(nodo.id_numero)
		# Si la conexión es doble vía (pueden ir y venir):

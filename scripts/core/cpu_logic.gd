extends Node

# --- MODELO DE DATOS (El Estado) ---

# La variable principal que rastrea la carga actual.
var carga_cpu: float = 0.0

# La carga máxima antes del colapso (Game Over).
const MAX_CARGA: float = 100.0

# El drenaje base pasivo por segundo (se configurará desde la oficina).
var base_cpu_drain: float = 0.0


# --- CONTROLADOR DE LÓGICA (El Motor) ---

# Se ejecuta en cada frame del juego.
func _process(delta):
	# 1. Aplicar el drenaje constante
	# (Solo si el juego no está en pausa o en Game Over)
	if not get_tree().paused and carga_cpu < MAX_CARGA:
		carga_cpu += base_cpu_drain * delta
		carga_cpu = clamp(carga_cpu, 0.0, MAX_CARGA) # Limita el valor entre 0 y 100

	# 2. Condición de DERROTA
	if carga_cpu >= MAX_CARGA:
		# ¡PERDISTE!
		print("COLAPSO DE CPU. ¡GAME OVER!")
		
		# Detenemos el juego para evitar errores en bucle
		get_tree().paused = true 
		
		# Carga la escena de Game Over (asegúrate de que la ruta sea correcta)
		get_tree().change_scene_to_file("res://scenes/ui/game_over_screen.tscn")

# --- FUNCIONES DE INTERFAZ (APIs) ---

# Esta función la llama la 'oficina' al inicio de la noche.
func set_base_drain(drain_por_segundo: float):
	base_cpu_drain = drain_por_segundo

# Esta función la llama 'office.gd' cuando el jugador escanea o usa un parche.
func aplicar_pulso_cpu(cantidad: float):
	# Solo aplica el pulso si el juego está activo
	if carga_cpu < MAX_CARGA:
		carga_cpu += cantidad
		print("Pulso de CPU aplicado: " + str(cantidad) + " | Nueva carga: " + str(carga_cpu))

# Función para reiniciar la CPU al comenzar una noche.
# Es llamada por 'office.gd' en _ready()
func reset_cpu():
	carga_cpu = 0.0
	get_tree().paused = false # Nos aseguramos de que el juego no esté pausado

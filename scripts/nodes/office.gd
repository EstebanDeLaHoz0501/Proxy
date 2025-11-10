extends Control # O el nodo raíz de tu oficina

# --- Referencias a la VISTA (Nodos de UI) ---
@onready var cpu_bar = $HUD/cpuBar # Ajusta esta ruta a tu ProgressBar
@onready var night_timer = $HUD/nightTimer # Ajusta esta ruta a tu Timer
@onready var kits_label = $HUD/kitsLabel # Ajusta esta ruta a tu Label de texto
@onready var wallclock = $HUD/time
# --- Referencias a los CONTROLADORES GLOBALES ---
# (No necesitas @onready si son Autoloads)
# Usamos @onready para esperar a que el árbol esté listo
@onready var CPU_Logic = get_node("/root/CPULOGIC") 
@onready var Player = get_node("/root/PLAYER")     
@onready var GameManager = get_node("/root/GAMEMANAGER")

# --- INICIALIZACIÓN DE LA VISTA ---
func _ready():
	# 1. Pide las REGLAS de la noche actual al GameManager
	var rules: NightBase = GameManager.current_night_data
	
	if rules == null:
		print("ERROR: No se cargaron reglas de noche en GameManager. Abortando.")
		get_tree().quit() # Salir si no hay reglas
		return

	# 2. Configura la escena (VISTA) usando las REGLAS (MODELO)
	night_timer.wait_time = rules.duration
	CPU_Logic.set_base_drain(rules.base_cpu_drain)
	Player.initialize_kits(rules.starting_kits)
	
	# 3. Inicia la noche
	night_timer.start()

# --- ACTUALIZACIÓN DE LA VISTA ---
func _process(delta):
	# 1. Actualizar la barra de CPU (Vista)
	cpu_bar.value = CPULOGIC.carga_cpu

	# 2. Actualizar el Label de Kits (Vista)
	kits_label.text = "KITS: " + str(Player.current_kits)

		# 3. Actualizar el reloj de la noche (Vista)
	var tiempo_restante = night_timer.time_left
	var minutos = int(tiempo_restante / 60)
	var segundos = int(tiempo_restante) - (minutos * 60)

	wallclock.text = "   "+"%d:%02d" % [minutos, segundos]


# --- CONTROLADOR DE ENTRADA ---
func _on_nodo_dns_pressed(): # Ejemplo de conexión de señal de un nodo del mapa
	# 1. Avisa al Controlador de CPU que aplique el costo
	CPU_Logic.aplicar_pulso(3.0) # Pulso del 3% por Escáner
	
	# 2. Lógica de escaneo (revelar malware, etc.)
	print("Escaneando nodo DNS...")

func _on_night_timer_timeout():
	# 3. Avisa al Controlador Global que ganamos
	GameManager.nivel_completado(GameManager.current_night_data.night_number) # Necesitarás añadir 'night_number' a tu NightBase
	get_tree().change_scene_to_file("res://scenes/ui/victory_screen.tscn")
	
	
func _on_button_back_to_menu_pressed() -> void:
	# 1. Detenemos cualquier lógica de CPU o Malware para evitar errores
	get_tree().paused = true 
	
	# 2. Reseteamos el estado de la CPU (importante para la próxima partida)
	CPU_Logic.reset_cpu() # Llama a la función que agregamos antes
	# 3. Regresamos al menú (asumiendo que la ruta es correcta)
	get_tree().change_scene_to_file("res://scenes/ui/menu.tscn")

func _on_scanner_button_pressed():
# Costo de la acción: 3% de CPU (el pulso)
	CPULOGIC.aplicar_pulso_cpu(3.0) 

# El escáner usa un kit de parcheo (ficticio, por ahora)
	Player.use_kit() 

# Aquí iría la lógica de escaneo visual
	print("¡Pulso de CPU y Kit aplicado!")
	
func _on_parch_button_pressed():
# Costo de la acción: 3% de CPU (el pulso)
	CPULOGIC.aplicar_pulso_cpu(5.0) 

# El escáner usa un kit de parcheo (ficticio, por ahora)
	Player.use_kit() 

# Aquí iría la lógica de escaneo visual
	print("¡Pulso de CPU y Kit aplicado!")
	
func _on_parch_3_button_pressed():
# Costo de la acción: 3% de CPU (el pulso)
	CPULOGIC.aplicar_pulso_cpu(15.0) 

# El escáner usa un kit de parcheo (ficticio, por ahora)
	Player.use_kit() 
	Player.use_kit() 
	Player.use_kit() 

# Aquí iría la lógica de escaneo visual
	print("¡Pulso de CPU y Kit aplicado!")

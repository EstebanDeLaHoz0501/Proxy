extends Control # O el nodo raíz de tu oficina

# --- Referencias a la VISTA (Nodos de UI) ---
@onready var cpu_bar = $HUD/cpuBar # Ajusta esta ruta a tu ProgressBar
@onready var night_timer = $HUD/nightTimer # Ajusta esta ruta a tu Timer
@onready var kits_label = $HUD/kitsLabel # Ajusta esta ruta a tu Label de texto
@onready var wallclock = $HUD/time
@onready var notification = $TextureRect2/Notif/Label
# --- Referencias a los CONTROLADORES GLOBALES ---
# (No necesitas @onready si son Autoloads)
# Usamos @onready para esperar a que el árbol esté listo
@onready var CPU_Logic = get_node("/root/CPULOGIC") 
@warning_ignore("shadowed_global_identifier")
@onready var Player = get_node("/root/PLAYER")     
@warning_ignore("shadowed_global_identifier")
@onready var GameManager = get_node("/root/GAMEMANAGER")
@onready var MapManager = get_node("/root/MAPMANAGER")



# --- 1. DEFINICIONES GLOBALES (AQUÍ DEBE IR) ---
enum Herramienta { NINGUNA, SCANNER, PARCHE, FIREWALL , PURGLOG}
var herramienta_actual = Herramienta.NINGUNA 

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
	if cpu_bar:
		cpu_bar.value = CPU_Logic.carga_cpu

	# 2. Actualizar el número de CPU (Si tienes un Label para el número)
	# Esto convierte 83.3333 en 83
	# Si no tienes un label llamado cpu_label, borra estas dos líneas:
	# if cpu_label:
	#    cpu_label.text = str(int(CPULogic.carga_cpu)) + "%"

	# 3. Actualizar el Label de Kits (Vista)
	if kits_label:
		kits_label.text = "KITS: " + str(Player.current_kits)

	# 4. Actualizar el reloj de la noche (Vista)
	if night_timer:
		var tiempo_restante = night_timer.time_left
		var minutos = int(tiempo_restante / 60)
		var segundos = int(tiempo_restante) - (minutos * 60)

	# Asegúrate de tener referenciado 'wallclock' con @onready arriba
		if wallclock:
			wallclock.text = "   " + "%d:%02d" % [minutos, segundos]


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

# Variables para recordar qué clic se está usando (para cuando termine el hold)
var ultimo_clic_usado: int = MOUSE_BUTTON_LEFT

# 1. Esta función le dice al botón cuánta CPU subir mientras mantiene presionado
func obtener_costo_cpu_herramienta(button_index: int, herramienta) -> float:
	ultimo_clic_usado = button_index # Guardamos esto para usarlo al final
	if herramienta == "SCANNER":
		herramienta_actual = Herramienta.SCANNER
	elif herramienta == "PARCHE":
		herramienta_actual = Herramienta.PARCHE
	elif herramienta == "FIREWALL":
		herramienta_actual = Herramienta.FIREWALL
	elif herramienta == "PURGLOG":
		herramienta_actual = Herramienta.PURGLOG
		
	match herramienta_actual:
		Herramienta.SCANNER:
			return 5.0 # El escáner consume 5% mientras se usa
		Herramienta.PARCHE:
			if button_index == MOUSE_BUTTON_LEFT:
				return 10.0 # Parche Lvl 1 consume 10% sostenido
			elif button_index == MOUSE_BUTTON_RIGHT:
				return 25.0 # Parche Lvl 3 consume mucho proceso
		Herramienta.PURGLOG:
			return 4.0
		Herramienta.FIREWALL:
			return 15.0

	return 0.0 # Si no hay herramienta, no hace nada

# 2. Esta función se ejecuta SOLO si la barra se llenó
func ejecutar_accion_final(id_nodo):
	var nodo = MapManager.todos_los_nodos_por_id[id_nodo]

	match herramienta_actual:
		Herramienta.SCANNER:
			# CORRECCIÓN 1: El escáner NO gasta kits. Solo muestra info.
			if(id_nodo==7):
				get_node("corenew").appear()
				print("Escaneo completado: " + nodo.nombre + " | Infección: " + str(nodo.nivel_infeccion))
			else:
				print("Escaneo completado: " + nodo.nombre + " | Infección: " + str(nodo.nivel_infeccion))
			# Aquí actualizas el color o pones un label con la info
		Herramienta.PURGLOG:
				nodo.nivel_infeccion =0
				get_node("corenew").appear()
				notification.text = "PurgLog completado.\n" + notification.text
		Herramienta.PARCHE:
			# CORRECCIÓN: Aquí sí gastamos kits
			
			if ultimo_clic_usado == MOUSE_BUTTON_LEFT:
				if Player.use_kit():
					nodo.nivel_infeccion = max(0, nodo.nivel_infeccion - 1)
					notification.text = "Parche completado.\n" + notification.text

			elif ultimo_clic_usado == MOUSE_BUTTON_RIGHT:
				print('heyy')
				if Player.use_super_patch():
					nodo.nivel_infeccion = 0
					notification.text = "Super Parche completado.\n" + notification.text
					
#-----------------------------------------------------------------
var open = false

func _on_cerrar_map_2_pressed() -> void:
	if open == false:
		get_node("MapBase/AnimationPlayer").play("open")
		open = true
	else:
		get_node("MapBase/AnimationPlayer").play("close")
		open = false

var cam = null

func _on_cam_1_pressed() -> void:
	if cam != "Cam1":
		get_node('MapCams').visible = true
		get_node('MapCams/Cam1').visible = true
		if cam != null:
			get_node(cam).visible = false
	cam = 'MapCams/Cam1'
	
func _on_cam_2_pressed() -> void:
	if cam != "Cam2":
		get_node('MapCams').visible = true
		get_node('MapCams/Cam2').visible = true
		if cam != null:
			get_node(cam).visible = false
	cam = 'MapCams/Cam2'
	
func _on_cam_3_pressed() -> void:
	if cam != "Cam3":
		get_node('MapCams').visible = true
		get_node('MapCams/Cam3').visible = true
		if cam != null:
			get_node(cam).visible = false
	cam = 'MapCams/Cam3'

func _on_cam_4_pressed() -> void:
	if cam != "Cam4":
		get_node('MapCams').visible = true
		get_node('MapCams/Cam4').visible = true
		if cam != null:
			get_node(cam).visible = false
	cam = 'MapCams/Cam4'
	
func _on_cam_5_pressed() -> void:
	if cam != "Cam5":
		get_node('MapCams').visible = true
		get_node('MapCams/Cam5').visible = true
		if cam != null:
			get_node(cam).visible = false
	cam = 'MapCams/Cam5'



func _on_scanner_pressed() -> void:
	get_node("MapScan").visible = true

func _on_parches_pressed() -> void:
	get_node("MapParch").visible = true

func _on_parches3_pressed() -> void:
	get_node("MapParch3").visible = true

func _on_firewalls_pressed() -> void:
	get_node("MapFirewalls").visible = true
	


func _on_button_back_cams_pressed() -> void:
	get_node('MapCams').visible = false
	get_node(cam).visible = false

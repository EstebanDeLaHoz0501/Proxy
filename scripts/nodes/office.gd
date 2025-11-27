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
var do = false
# --- INICIALIZACIÓN DE LA VISTA ---
func _ready():
	# 1. Pide las REGLAS de la noche actual al GameManager
	var rules: NightBase = GameManager.current_night_data
	GAMEMANAGER.registrarEscena(self)
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

var popuptimelimit = 3
var popuptime = 0
# --- ACTUALIZACIÓN DE LA VISTA ---
func _process(delta):
	# 1. Actualizar la barra de CPU (Vista)
	if cpu_bar:
		cpu_bar.value = CPU_Logic.carga_cpu
	if do == true:
		popuptime += delta
		$ProgressBar.value = (popuptime / popuptimelimit) * 100
		if ($ProgressBar.value == 100 and 
			($Popup1.visible == true or
			$Popup2.visible == true or
			$Popup3.visible == true)):
			GAMEMANAGER.trigger_game_over('PopUp')
		elif($ProgressBar.value < 100 and 
			($Popup1.visible == false and
			$Popup2.visible == false and
			$Popup3.visible == false)):
			do = false
			$ProgressBar.visible = false
			$Popup1.visible = false
			$Popup2.visible = false
			$Popup3.visible = false
			MAPMANAGER.getMalware('VirusPopup').volver_a_origen()
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
	if night_timer.time_left <= 1:
		$win.visible= true
		$win/winsound.play()
		$win/animacionwin.play('appear')
		await get_tree().create_timer(6.0).timeout
		
		MAPMANAGER.lista_malwares_activos.clear()
		
		print("Volviendo al menú...")
		get_tree().change_scene_to_file("res://scenes/ui/menu.tscn")
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
			return 5.0/3 # El escáner consume 5% mientras se usa
		Herramienta.PARCHE:
			if button_index == MOUSE_BUTTON_LEFT:
				return 10.0/3 # Parche Lvl 1 consume 10% sostenido
			elif button_index == MOUSE_BUTTON_RIGHT:
				return 25.0/3 # Parche Lvl 3 consume mucho proceso
		Herramienta.PURGLOG:
			return 4.0/4
		Herramienta.FIREWALL:
			return 15.0 #ni se usa

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
				notification.text = "Escaneo completado:" + nodo.nombre + " | Infección: " + str(nodo.nivel_infeccion)+"\n" + notification.text
			# Aquí actualizas el color o pones un label con la info
		Herramienta.PURGLOG:
				nodo.nivel_infeccion =0
				for mal in MAPMANAGER.lista_malwares_activos:
					if(mal.nodo_actual == nodo):
						mal.volver_a_origen()
				get_node("corenew").appear()
				notification.text = "PurgLog completado.\n" + notification.text
		Herramienta.PARCHE:
			# CORRECCIÓN: Aquí sí gastamos kits
			
			if ultimo_clic_usado == MOUSE_BUTTON_LEFT:
				if Player.use_kit():
					nodo.nivel_infeccion = 0
					for mal in MAPMANAGER.lista_malwares_activos:
						if(mal.nodo_actual == nodo):
							mal.progreso_conquista = 0
					notification.text = "Parche completado.\n" + notification.text

			elif ultimo_clic_usado == MOUSE_BUTTON_RIGHT:
				print('heyy')
				if Player.use_super_patch():
					nodo.nivel_infeccion = 0
					for mal in MAPMANAGER.lista_malwares_activos:
						if(mal.nodo_actual == nodo):
							mal.volver_a_origen()
							mal.progreso_conquista = 0
					notification.text = "Super Parche completado.\n" + notification.text
					
#-----------------------------------------------------------------

func trigger_PopUp():
		var p1x = randi_range(20, 300)   
		var p1y = randi_range(100, 300)   
		$Popup1.position = Vector2(p1x, p1y)
		$Popup1.visible = true
		
		var p2x = randi_range(20, 300)   
		var p2y = randi_range(100, 300)   
		$Popup2.position = Vector2(p2x, p2y)
		$Popup2.visible = true
		
		var p3x = randi_range(20, 300)   
		var p3y = randi_range(100, 300)   
		$Popup3.position = Vector2(p3x, p3y)
		$Popup3.visible = true
		
		$ProgressBar.visible = true
		popuptime = 0


	
	
#-----------------------------------------------------------------
var open = false

func _on_cerrar_map_2_pressed() -> void:
	if open == false:
		get_node("MapBase/AnimationPlayer").play("open")
		$MapBase/TextureRect/TextureRect2/CerrarMap2/openmapsound.play()#efecto de sonido
		open = true
	else:
		get_node("MapBase/AnimationPlayer").play("close")
		open = false

var cam = null

func _on_cam_1_pressed() -> void:
	if cam != 'MapCams/Cam1':
		get_node('MapCams').visible = true
		get_node('MapCams/Cam1').visible = true
		$MapCams/Cam1/camerasound.play()
		$MapCams/Cam1/popup.visible = false
		$MapCams/Cam1/popup2.visible = false
		$MapCams/Cam1/popup3.visible = false
		if MAPMANAGER.getMalware('Phishing').nodo_actual.id_numero == 1 and MAPMANAGER.getMalware('Phishing').nodo_actual.nivel_infeccion > 0:
			var px = randi_range(20, 600)   
			var py = randi_range(100, 400)   
			$MapCams/Cam1/phishing.position = Vector2(px, py)
			$MapCams/Cam1/phishing.visible = true
		else:
			$MapCams/Cam1/phishing.visible = false
		if MAPMANAGER.getMalware('Worm').nodo_actual.id_numero == 1 and MAPMANAGER.getMalware('Worm').nodo_actual.nivel_infeccion > 0:
			var wx = randi_range(20, 300)   
			var wy = randi_range(100, 300)   
			$MapCams/Cam1/worm.position = Vector2(wx, wy)
			$MapCams/Cam1/worm.visible = true
		else:
			$MapCams/Cam1/worm.visible = false
		if MAPMANAGER.getMalware('VirusPopup').nodo_actual.id_numero == 1 and MAPMANAGER.getMalware('VirusPopup').nodo_actual.nivel_infeccion > 0:
			var randompop = randi_range(1, 3)   
			var vpx = randi_range(20, 300)   
			var vpy = randi_range(100, 300)
			print('popup en 1')
			if(randompop==1): 
				$MapCams/Cam1/popup.position = Vector2(vpx, vpy)
				$MapCams/Cam1/popup.visible = true
			elif(randompop==2):
				$MapCams/Cam1/popup2.position = Vector2(vpx, vpy)
				$MapCams/Cam1/popup2.visible = true
			elif(randompop==3):
				$MapCams/Cam1/popup3.position = Vector2(vpx, vpy)
				$MapCams/Cam1/popup3.visible = true
		else:
			$MapCams/Cam1/popup.visible = false
			$MapCams/Cam1/popup2.visible = false
			$MapCams/Cam1/popup3.visible = false
		if cam != null:
			get_node(cam).visible = false
	cam = 'MapCams/Cam1'
	
func _on_cam_2_pressed() -> void:
	if cam != 'MapCams/Cam2':
		get_node('MapCams').visible = true
		get_node('MapCams/Cam2').visible = true
		$MapCams/Cam2/camerasound.play() #efecto especial de sonido
		$MapCams/Cam2/popup.visible = false
		$MapCams/Cam2/popup2.visible = false
		$MapCams/Cam2/popup3.visible = false
		if MAPMANAGER.getMalware('Phishing').nodo_actual.id_numero == 2 and MAPMANAGER.getMalware('Phishing').nodo_actual.nivel_infeccion > 0:
			var px = randi_range(20, 600)   
			var py = randi_range(100, 400)   
			$MapCams/Cam2/phishing.position = Vector2(px, py)
			$MapCams/Cam2/phishing.visible = true
		else:
			$MapCams/Cam2/phishing.visible = false
		if MAPMANAGER.getMalware('Worm').nodo_actual.id_numero == 2 and MAPMANAGER.getMalware('Worm').nodo_actual.nivel_infeccion > 0:
			var wx = randi_range(20, 600)   
			var wy = randi_range(100, 400)   
			$MapCams/Cam2/worm.position = Vector2(wx, wy)
			$MapCams/Cam2/worm.visible = true
		else:
			$MapCams/Cam2/worm.visible = false
		if MAPMANAGER.getMalware('VirusPopup').nodo_actual.id_numero == 2 and MAPMANAGER.getMalware('VirusPopup').nodo_actual.nivel_infeccion > 0:
			var randompop = randi_range(1, 3)   
			var vpx = randi_range(20, 600)   
			var vpy = randi_range(100, 400)
			print('popup en 1')
			if(randompop==1): 
				$MapCams/Cam2/popup.position = Vector2(vpx, vpy)
				$MapCams/Cam2/popup.visible = true
			elif(randompop==2):
				$MapCams/Cam2/popup2.position = Vector2(vpx, vpy)
				$MapCams/Cam2/popup2.visible = true
			elif(randompop==3):
				$MapCams/Cam2/popup3.position = Vector2(vpx, vpy)
				$MapCams/Cam2/popup3.visible = true
		else:
			$MapCams/Cam2/popup.visible = false
			$MapCams/Cam2/popup2.visible = false
			$MapCams/Cam2/popup3.visible = false
		if cam != null:
			get_node(cam).visible = false
	cam = 'MapCams/Cam2'
	
func _on_cam_3_pressed() -> void:
	if cam != 'MapCams/Cam3':
		get_node('MapCams').visible = true
		get_node('MapCams/Cam3').visible = true
		$MapCams/Cam3/camerasound.play() #efecto especial de sonido
		$MapCams/Cam3/popup.visible = false
		$MapCams/Cam3/popup2.visible = false
		$MapCams/Cam3/popup3.visible = false
		if MAPMANAGER.getMalware('Phishing').nodo_actual.id_numero == 3 and MAPMANAGER.getMalware('Phishing').nodo_actual.nivel_infeccion > 0:
			var px = randi_range(20, 600)   
			var py = randi_range(100, 400)   
			$MapCams/Cam3/phishing.position = Vector2(px, py)
			$MapCams/Cam3/phishing.visible = true
		else:
			$MapCams/Cam3/phishing.visible = false
		if MAPMANAGER.getMalware('Worm').nodo_actual.id_numero == 3 and MAPMANAGER.getMalware('Worm').nodo_actual.nivel_infeccion > 0:
			var wx = randi_range(20, 600)   
			var wy = randi_range(100, 400)   
			$MapCams/Cam3/worm.position = Vector2(wx, wy)
			$MapCams/Cam3/worm.visible = true
		else:
			$MapCams/Cam3/worm.visible = false
		if MAPMANAGER.getMalware('VirusPopup').nodo_actual.id_numero == 3 and MAPMANAGER.getMalware('VirusPopup').nodo_actual.nivel_infeccion > 0:
			var randompop = randi_range(1, 3)   
			var vpx = randi_range(20, 600)   
			var vpy = randi_range(100, 400)
			print('popup en 1')
			if(randompop==1): 
				$MapCams/Cam3/popup.position = Vector2(vpx, vpy)
				$MapCams/Cam3/popup.visible = true
			elif(randompop==2):
				$MapCams/Cam3/popup2.position = Vector2(vpx, vpy)
				$MapCams/Cam3/popup2.visible = true
			elif(randompop==3):
				$MapCams/Cam3/popup3.position = Vector2(vpx, vpy)
				$MapCams/Cam3/popup3.visible = true
		else:
			$MapCams/Cam3/popup.visible = false
			$MapCams/Cam3/popup2.visible = false
			$MapCams/Cam3/popup3.visible = false
		if cam != null:
			get_node(cam).visible = false
	cam = 'MapCams/Cam3'

func _on_cam_4_pressed() -> void:
	if cam !=  'MapCams/Cam4':
		get_node('MapCams').visible = true
		get_node('MapCams/Cam4').visible = true
		$MapCams/Cam4/camerasound.play() #efecto especial de sonido
		$MapCams/Cam4/popup.visible = false
		$MapCams/Cam4/popup2.visible = false
		$MapCams/Cam4/popup3.visible = false
		if MAPMANAGER.getMalware('Phishing').nodo_actual.id_numero == 4 and MAPMANAGER.getMalware('Phishing').nodo_actual.nivel_infeccion > 0:
			var px = randi_range(20, 600)   
			var py = randi_range(100, 400)   
			$MapCams/Cam4/phishing.position = Vector2(px, py)
			$MapCams/Cam4/phishing.visible = true
		else:
			$MapCams/Cam4/phishing.visible = false
		if MAPMANAGER.getMalware('Worm').nodo_actual.id_numero == 4 and MAPMANAGER.getMalware('Worm').nodo_actual.nivel_infeccion > 0:
			var wx = randi_range(20, 600)   
			var wy = randi_range(100, 400)   
			$MapCams/Cam4/worm.position = Vector2(wx, wy)
			$MapCams/Cam4/worm.visible = true
		else:
			$MapCams/Cam4/worm.visible = false
		if MAPMANAGER.getMalware('VirusPopup').nodo_actual.id_numero == 4 and MAPMANAGER.getMalware('VirusPopup').nodo_actual.nivel_infeccion > 0:
			var randompop = randi_range(1, 3)   
			var vpx = randi_range(20, 600)   
			var vpy = randi_range(100, 400)
			print('popup en 1')
			if(randompop==1): 
				$MapCams/Cam4/popup.position = Vector2(vpx, vpy)
				$MapCams/Cam4/popup.visible = true
			elif(randompop==2):
				$MapCams/Cam4/popup2.position = Vector2(vpx, vpy)
				$MapCams/Cam4/popup2.visible = true
			elif(randompop==3):
				$MapCams/Cam4/popup3.position = Vector2(vpx, vpy)
				$MapCams/Cam4/popup3.visible = true
		else:
			$MapCams/Cam4/popup.visible = false
			$MapCams/Cam4/popup2.visible = false
			$MapCams/Cam4/popup3.visible = false
		if cam != null:
			get_node(cam).visible = false
	cam = 'MapCams/Cam4'
	
func _on_cam_5_pressed() -> void:
	if cam != 'MapCams/Cam5':
		get_node('MapCams').visible = true
		get_node('MapCams/Cam5').visible = true
		$MapCams/Cam5/camerasound.play() #efecto especial de sonido
		$MapCams/Cam5/popup.visible = false
		$MapCams/Cam5/popup2.visible = false
		$MapCams/Cam5/popup3.visible = false
		if MAPMANAGER.getMalware('Phishing').nodo_actual.id_numero == 5 and MAPMANAGER.getMalware('Phishing').nodo_actual.nivel_infeccion > 0 :
			var px = randi_range(20, 600)   
			var py = randi_range(100, 400)   
			$MapCams/Cam5/phishing.position = Vector2(px, py)
			$MapCams/Cam5/phishing.visible = true
		else:
			$MapCams/Cam5/phishing.visible = false
		if MAPMANAGER.getMalware('Worm').nodo_actual.id_numero == 5 and MAPMANAGER.getMalware('Worm').nodo_actual.nivel_infeccion > 0:
			var wx = randi_range(20, 600)   
			var wy = randi_range(100, 400)   
			$MapCams/Cam5/worm.position = Vector2(wx, wy)
			$MapCams/Cam5/worm.visible = true
		else:
			$MapCams/Cam5/worm.visible = false
		if MAPMANAGER.getMalware('VirusPopup').nodo_actual.id_numero == 5 and MAPMANAGER.getMalware('VirusPopup').nodo_actual.nivel_infeccion > 0:
			var randompop = randi_range(1, 3)   
			var vpx = randi_range(20, 600)   
			var vpy = randi_range(100, 400)
			print('popup en 1')
			if(randompop==1): 
				$MapCams/Cam5/popup.position = Vector2(vpx, vpy)
				$MapCams/Cam5/popup.visible = true
			elif(randompop==2):
				$MapCams/Cam5/popup2.position = Vector2(vpx, vpy)
				$MapCams/Cam5/popup2.visible = true
			elif(randompop==3):
				$MapCams/Cam5/popup3.position = Vector2(vpx, vpy)
				$MapCams/Cam5/popup3.visible = true
		else:
			$MapCams/Cam5/popup.visible = false
			$MapCams/Cam5/popup2.visible = false
			$MapCams/Cam5/popup3.visible = false
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
	cam = null


func _on_popup_1_hide_pressed() -> void:
	$Popup1.visible = false

func _on_popup_2_hide_pressed() -> void:
	$Popup2.visible = false

func _on_popup_3_hide_pressed() -> void:
	$Popup3.visible = false


#func win_game():
	#$win.visible = true
#
	## Sonido de campanas (opcional)
	#$win/AudioStreamPlayer2D.play()
#
	## Reproducir animación 5 → 6
	#$win/fivetosix.play("five_to_six")
#
	#await $win/fivetosix.animation_finished
#
	## Guardar progreso de noches
	#var save = FileAccess.open("user://save.dat", FileAccess.WRITE)
	#save.store_string("night2_unlocked")
	#save.close()
#
	#get_tree().change_scene_to_file("res://scenes/ui/menu.tscn")

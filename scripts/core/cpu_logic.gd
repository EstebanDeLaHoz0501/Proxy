extends Node

# --- MODELO DE DATOS ---
var carga_cpu: float = 0.0
const MAX_CARGA: float = 100.0
var firewall = 0
# 1. ENFRIAMIENTO PASIVO (Lo que pediste: bajar 1% cada 3 segundos)
# 1 dividido entre 3 = 0.333 por segundo.
var tasa_enfriamiento: float = 0.33 

# 2. CARGA ACTIVA (Sube mientras mantienes presionado Scanner/Parche)
var carga_procesos_activos: float = 0.0
var ConsumoWorm: float = 0.0
func _process(delta):
	if get_tree().paused: return
	
	# --- LÓGICA DE TEMPERATURA ---
	# La CPU intenta enfriarse siempre (- tasa_enfriamiento)
	# Pero los procesos activos la calientan (+ carga_procesos_activos)
	
	var cambio_neto = (carga_procesos_activos + ConsumoWorm - tasa_enfriamiento) * delta
	carga_cpu += cambio_neto
	
	# Mantenemos la carga entre 0 y 100
	carga_cpu = clamp(carga_cpu, 0.0, MAX_CARGA)
	
	# Condición de DERROTA
	if carga_cpu >= MAX_CARGA:
		print("COLAPSO DE CPU. ¡GAME OVER!")
		get_tree().paused = true 
		get_tree().change_scene_to_file("res://scenes/ui/game_over_screen.tscn")

# --- APIs PARA LA OFICINA ---

# Llamado por 'office.gd' para golpes instantáneos (ej. activar Firewall)
func aplicar_pulso_cpu(cantidad: float):
	if carga_cpu < MAX_CARGA:
		carga_cpu += cantidad
		# Clamp inmediato para evitar pasarse visualmente por un frame
		carga_cpu = clamp(carga_cpu, 0.0, MAX_CARGA)

func reset_cpu():
	carga_cpu = 0.0
	tasa_enfriamiento = 0.33 # Reiniciamos al valor base
	carga_procesos_activos = 0.0
	get_tree().paused = false 

# --- LÓGICA DE BOTONES SOSTENIDOS ---

func iniciar_proceso_pesado(costo_temporal: float):
	carga_procesos_activos += costo_temporal

func detener_proceso_pesado(costo_temporal: float):
	carga_procesos_activos -= costo_temporal
	# Seguridad para que nunca quede negativo por errores de redondeo
	if carga_procesos_activos < 0: carga_procesos_activos = 0.0
	
func on_firewall():
	carga_procesos_activos += 1
func off_firewall():
	carga_procesos_activos -= 1
	
func set_base_drain(valor: float):
	# Esta función recibe la orden de Office y actualiza la variable local
	tasa_enfriamiento = max(0.1, 0.5 - (valor * 0.1))

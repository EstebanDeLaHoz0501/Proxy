extends Button

@export var id_nodo_asociado: int = 1 
@export var hold_time_required := 3 # Tiempo que tarda en completarse

var hold_timer := 0.0
var is_holding := false
var costo_cpu_actual := 0.0 # Para saber cuánto restar al soltar

# Referencias
@onready var office = get_tree().current_scene 
@onready var CPULogic = CPULOGIC
@onready var progress_bar = get_parent().get_node("ProgressBar") # Asumiendo que es hijo del botón

func _ready():
	progress_bar.hide()
	progress_bar.value = 0

func _process(delta):
	# Lógica de MANTENER presionado
	if is_holding:
		hold_timer += delta
		if(self.name=='PurgLog'):
			hold_time_required = 5
			progress_bar.value = (hold_timer / hold_time_required) * 100
		else:
			hold_time_required = 3
			progress_bar.value = (hold_timer / hold_time_required) * 100
		
		# Si se completó el tiempo
		if hold_timer >= hold_time_required:
			terminar_accion(true) # true = Acción completada con éxito

# --- DETECCIÓN DE INPUT (INICIO) ---
func _gui_input(event):
	if event is InputEventMouseButton and event.pressed and not is_holding:
		print(event.button_index)
		iniciar_accion(event.button_index)

	elif event is InputEventMouseButton and not event.pressed and is_holding:
		# Si suelta el botón antes de tiempo
		terminar_accion(false) # false = Cancelado

# --- LÓGICA DE PROCESOS (CPU Y BARRA) ---

func iniciar_accion(button_index: int):
	# 1. Preguntar a la Oficina qué herramienta tengo y cuánto cuesta de CPU
	var herramienta
	if (self.name == 'CamParch1' or self.name == 'CamParch2' or 
		self.name == 'CamParch3' or self.name == 'CamParch4' or 
		self.name == 'CamParch5'):
		herramienta = "PARCHE"
	elif (self.name == 'CamScan1' or self.name == 'CamScan2' or 
		self.name == 'CamScan3' or self.name == 'CamScan4' or 
		self.name == 'CamScan5' or self.name == 'NucleoScan'):
		herramienta = "SCANNER"
	elif (self.name == 'PurgLog'):
		herramienta = "PURGLOG"
		
	if (self.name == 'CamParch1' or self.name == 'CamScan1'):
		id_nodo_asociado = 1	
	elif (self.name == 'CamParch2' or self.name == 'CamScan2'):
		id_nodo_asociado = 2	
	elif (self.name == 'CamParch3' or self.name == 'CamScan3'):
		id_nodo_asociado = 3
	elif (self.name == 'CamParch4' or self.name == 'CamScan4'):
		id_nodo_asociado = 4
	elif (self.name == 'CamParch5' or self.name == 'CamScan5'):
		id_nodo_asociado = 5
	elif (self.name == 'NucleoScan' or self.name == 'PurgLog'):
		id_nodo_asociado = 7
	# (Necesitamos una función en office que nos diga el costo sin ejecutar la acción aún)
	costo_cpu_actual = office.obtener_costo_cpu_herramienta(button_index, herramienta)
	
	if costo_cpu_actual > 0:
		is_holding = true
		hold_timer = 0.0
		progress_bar.show()
		
		# 2. AVISAR A LA CPU QUE SUBA (Simula abrir el programa)
		CPULogic.iniciar_proceso_pesado(costo_cpu_actual)

func terminar_accion(exito: bool):
	is_holding = false
	hold_timer = 0.0
	progress_bar.hide()
	progress_bar.value = 0
	
	# 1. AVISAR A LA CPU QUE BAJE (Simula cerrar el programa)
	CPULogic.detener_proceso_pesado(costo_cpu_actual)
	
	# 2. Si se completó la barra, ejecutamos el efecto real
	if exito:
		# Enviamos el id y el costo 0 (porque ya lo cobramos temporalmente)
		# Ojo: necesitamos saber qué botón del mouse inició esto. 
		# Para simplificar, asumimos que la oficina sabe qué herramienta tiene.
		# Pero necesitamos pasarle el tipo de clic correcto.
		
		# Truco: Recuperamos el último clic o simplemente le decimos a la oficina que ejecute
		office.ejecutar_accion_final(id_nodo_asociado)

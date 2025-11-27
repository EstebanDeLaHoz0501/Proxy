extends Button

# --- VARIABLES DE CONFIGURACIÓN ---
@export var hold_time_required := 1.5

# --- VARIABLES DE ESTADO ---
var hold_timer := 0.0
var is_holding := false
var activated := false
var drain_timer := 0.0
var cooldown := false 

@onready var progress_bar = get_parent().get_node("ProgressBar")

func _ready():
	#limpieza visual
	#if pressed.is_connected(_on_long_press): pressed.disconnect(_on_long_press)
	button_down.connect(_on_button_down_logic)
	button_up.connect(_on_button_up_logic)
	
	#estado inicial visual
	progress_bar.hide()
	progress_bar.value = 0
	self.text = "" #asegura que empiece sin texto(vacio)
	self.remove_theme_color_override("font_color")

#la funcion delta para frames y time
func _process(delta):
	if is_holding and not activated:
		hold_timer += delta
		progress_bar.value = (hold_timer / hold_time_required) * 100
		if hold_timer >= hold_time_required:
			_trigger_activation()

	if activated:
		drain_timer += delta
		if drain_timer >= 3.0:
			drain_timer = 0.0
			_apply_drain_tick()

#se presiona el boton
func _on_button_down_logic():
	if cooldown: return 
	
	if activated:
		_deactivate_firewall()
	else:
		is_holding = true
		hold_timer = 0.0
		progress_bar.show()

#se deja de presionar el boton
func _on_button_up_logic():
	if is_holding:
		is_holding = false
		hold_timer = 0.0
		progress_bar.hide()
		progress_bar.value = 0

#aqui va la logica
func _trigger_activation():
	is_holding = false 
	activated = true
	
	#texto que aparece
	self.text = "Firewall ON" 
	self.add_theme_color_override("font_color", Color(0, 1, 0)) # Verde
	progress_bar.hide()
	
	_start_cooldown()

	#consumo inicial
	var office = get_tree().current_scene
	if office.has_method("_on_firewall_button_pressed"):
		office._on_firewall_button_pressed()

#desactiva el firewall
func _deactivate_firewall():
	activated = false
	drain_timer = 0.0
	is_holding = false
	
	#quita el texto
	self.text = "" 
	self.remove_theme_color_override("font_color") 
	
	progress_bar.hide()
	progress_bar.value = 0
	
	_start_cooldown()

#para el consumo mientras el firewall esta activo
func _apply_drain_tick():
	var office = get_tree().current_scene
	if office.has_method("_on_firewall_tick"):
		office._on_firewall_tick()

#necesario para evitar bugs
func _start_cooldown():
	cooldown = true
	await get_tree().create_timer(0.5).timeout
	cooldown = false
# ESTO SE DEBE HACER ANTES DE QUE _on_long_press ESTÉ DEFINIDO
# YA QUE "pressed" ES UNA SEÑAL INTEGRADA Y SI SE CONECTÓ EN EL EDITOR
# CAUSARÁ EL BUG DE ACTIVACIÓN INSTANTÁNEA.


#func _on_long_press():
	# Esta función ya no la usamos directamente, la lógica está en _trigger_activation
	#pass

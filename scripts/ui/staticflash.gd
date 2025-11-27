#CODE EN CASO DE QUE SE QUIERA MOSTRAR POR 1SEG 
#extends AnimatedSprite2D
#
#func _ready():
	## 1. Aseguramos que empiece visible y reproduciendo
	#visible = true 
	#play("flash") 
	#
	## 2. Creamos un temporizador de 1 segundo y esperamos a que termine
	#await get_tree().create_timer(1.0).timeout
	#
	#visible = false 
	#stop()
	
# DEJA LAS LINEAS ANIMADAS PARA SIEMPRE
extends AnimatedSprite2D

func _ready():
	visible = false
	play("flash")

	# mostrarla justo cuando empiece
	visible = true

	# esperar a que termine
	await animation_finished

	# ocultar después del flash
	visible =false 

extends AudioStreamPlayer

func _ready():
	play()
	finished.connect(_on_finished)

func _on_finished():
	play() # vuelve a empezar cuando termina

func _on_audio_stream_player_finished():
	$AudioStreamPlayer.play() 
	# Esto le obliga a reproducirse de nuevo apenas termina.

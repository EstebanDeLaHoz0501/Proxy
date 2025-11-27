extends Control

func _on_volver_core_pressed() -> void:
	self.visible = false
	
var lista = MAPMANAGER.lista_malwares_activos
var Nro

func getSpyware():
	lista = MAPMANAGER.lista_malwares_activos
	for mal in lista:
		if(mal.nombre=="Spyware"):
			return mal

func appear():
	Nro = self.getSpyware().nodo_actual.nivel_infeccion
	if Nro == 0:
		get_node("sp1").visible = false
		get_node("sp2").visible = false
		get_node("sp3").visible = false
	elif Nro == 1:
		get_node("sp1").visible = true
	elif Nro == 2:
		get_node("sp1").visible = true
		get_node("sp2").visible = true
	elif Nro == 3:
		get_node("sp1").visible = true
		get_node("sp2").visible = true
		get_node("sp3").visible = true

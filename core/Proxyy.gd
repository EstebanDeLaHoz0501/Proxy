extends Node
class_name Proxy

var _jugadorActual
var _jugadores =[]
var _niveles =[]
var _virus=[]
func _init():
	
	self._niveles.append(Nivel.new(1))
	self._niveles.append(Nivel.new(2))
	self._niveles.append(Nivel.new(3))
	self._niveles.append(Nivel.new(4))
	self._niveles.append(Nivel.new(5))
	
	self._virus.append(Spyware.new())
	self._virus.append(Worm.new())
	self._virus.append(Popup.new())
	self._virus.append(Phising.new())
	self._virus.append(Ransomware.new())
	
	
func addJugadores(jugador):
	self._jugadores.append(jugador)

func getNivel(dif):
	for nivel in self._niveles:
		if nivel.getdificultad()==dif:
			return nivel
	return null
func setJugadorAcual (jugador):
	self._jugadorAcual = jugador
	
func getJugadorActual():
	return self._jugadorActual
	
func getNiveles():
	return self._niveles

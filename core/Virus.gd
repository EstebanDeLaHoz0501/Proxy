@abstract
class_name Virus

var _nombre
var _nodoActual
func _init(n):
	self._nombre=n
@abstract
func move()

@abstract
func act()

@abstract
func jumpscare()

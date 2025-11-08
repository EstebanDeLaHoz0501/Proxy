extends Node
class_name Player

# --- MODELO DE DATOS DEL JUGADOR ---
var current_kits: int = 0

# --- CONTROLADOR DE DATOS ---

# Lo llama la 'oficina' al inicio de la noche
func initialize_kits(amount: int):
	current_kits = amount

# Lo llamas desde 'office.gd' cuando el jugador usa un Parche
func use_kit() -> bool:
	if current_kits > 0:
		current_kits -= 1
		print("Kit usado. Quedan: ", current_kits)
		return true # Se pudo usar
	else:
		print("¡No quedan kits!")
		return false # No se pudo usar

# Lo llamas cuando usas un Superparche (3 kits)
func use_super_patch() -> bool:
	if current_kits >= 3:
		current_kits -= 3
		print("Superparche usado. Quedan: ", current_kits)
		return true
	else:
		print("¡No hay suficientes kits para el Superparche!")
		return false

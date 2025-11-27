extends Resource # <-- Usamos Resource para que sea un contenedor de DATOS

class_name NightBase
# --- Propiedades Base (Reglas) ---

# Duración de la noche en segundos (5 minutos)
@export var duration: float = 300

# Drenaje base de CPU por segundo (1% cada 5s = 0.2 por segundo)
@export var base_cpu_drain: float = 0.2 

# Kits de parcheo iniciales
@export var starting_kits: int = 9

# (Opcional) Array de qué malware spawnear
@export var malware_spawns: Array

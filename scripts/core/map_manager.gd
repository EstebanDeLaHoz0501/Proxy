# res://scripts/core/map_manager.gd (Tu nuevo Autoload)
extends Node

var todos_los_nodos: Dictionary = {} # Para buscarlos por nombre
var todos_los_nodos_por_id: Dictionary = {} # Para buscarlos por ID (1, 2, 3...)
var lista_malwares_activos: Array = [] 
var firewall_timer = Timer.new() 
var ultimo_firewall_activado: int = -1

func crear_mapa_backend():
	print("--- Construyendo Grafo de Nodos (ID 1-7) ---")
	
	# 1. CREACIÓN DE NODOS (VÉRTICES)
	var n1_pasarela = NodoRed.new(1, "Pasarela", "Gateway") 
	var n2_dns = NodoRed.new(2, "Servidor_DNS", "Server") 
	var n3_serv_msg = NodoRed.new(3, "Servidor_Mensajeria", "Server")
	var n4_cont_dom = NodoRed.new(4, "Controlador_Dominios", "Server")
	var n5_repo = NodoRed.new(5, "Repositorio_Codigo", "Server")
	var n6_av_cons = NodoRed.new(6, "AV_Console", "Server") 
	var n7_nucleo = NodoRed.new(7, "Nucleo_DB", "Core") 

	# 2. ASIGNAR FUNCIONES ESPECIALES (BANDERAS)
	
	# [NODO 1] Pasarela
	n1_pasarela.es_gateway = true
	
	# [NODO 4] Controlador de Dominios
	n4_cont_dom.es_objetivo_worm = true 
	
	# [NODO 7] Núcleo
	n7_nucleo.es_nucleo = true

	# 3. GUARDAR LOS NODOS
	var nodos_creados = [n1_pasarela, n2_dns, n3_serv_msg, n4_cont_dom, n5_repo, n6_av_cons, n7_nucleo]
	
	for nodo in nodos_creados:
		todos_los_nodos[nodo.nombre] = nodo
		todos_los_nodos_por_id[nodo.id_numero] = nodo

	# 4. CREAR CONEXIONES (ARISTAS) - SIGUIENDO TU DIAGRAMA
	# [1] Pasarela se conecta con [2] y [3]
	n1_pasarela.conectar_con(n2_dns) 
	n1_pasarela.conectar_con(n3_serv_msg)
	
	# [2] DNS se conecta con [4] y [6]
	n2_dns.conectar_con(n4_cont_dom)
	n2_dns.conectar_con(n6_av_cons)
	
	# [3] Servidor Mensajería se conecta con [5]
	n3_serv_msg.conectar_con(n5_repo)
	
	# [4] Controlador Dominios se conecta con [7] (Núcleo)
	n4_cont_dom.conectar_con(n7_nucleo) 
	n4_cont_dom.conectar_con(n6_av_cons)
	
	# [5] Repositorio se conecta con [7]
	n5_repo.conectar_con(n7_nucleo)
	
	# [6] AV Console se conecta con [7]
	n6_av_cons.conectar_con(n7_nucleo) 

	print("Grafo de Nodos COMPLETADO: 7 Vértices definidos.")
	

func spawn_malware_inicial():
	print("--- SPANWEO DE MALWARE ---")

	# --- 1. ENCONTRAR NODOS CLAVE ---
	var nodo_pasarela = todos_los_nodos_por_id[1]
	var nodo_serv_msg = todos_los_nodos_por_id[3]
	var nodo_nucleo = todos_los_nodos_por_id[7]

	# --- 2. SPAWNEAR MALWARES Y AÑADIRLOS A LA LISTA ---
	
	# A. Spawn en PASARELA (Nodo 1: Ransomware, Worm, Popup)
	var ransom = MalwareBase.new("Ransomware", nodo_pasarela)
	var worm = MalwareBase.new("Worm", nodo_pasarela)
	var popup = MalwareBase.new("PopUp", nodo_pasarela)
	
	# B. Spawn en SERVIDOR MENSAJERÍA (Nodo 3: Phishing)
	var phishing = MalwareBase.new("Phishing", nodo_serv_msg)

	# C. Spawn en NÚCLEO (Nodo 7: Spyware)
	var spyware = MalwareBase.new("Spyware", nodo_nucleo)
	
	# 3. GUARDAR TODOS LOS MALWARES ACTIVOS
	# Aquí deberías usar tu Lista Enlazada, pero para simplicidad, usamos Array:
	lista_malwares_activos.append(ransom)
	lista_malwares_activos.append(worm)
	lista_malwares_activos.append(popup)
	lista_malwares_activos.append(phishing)
	lista_malwares_activos.append(spyware)
	
	print("Total de Malwares activos: " + str(lista_malwares_activos.size()))
	
	# 🚨 NOTA IMPORTANTE: 
	# Para el Spyware y Popup, debes sobrescribir la clase base para su lógica especial.
	# Por ahora, se moverán como cualquier otro virus, pero esto nos da la base.

# Llamar a spawn_malware_inicial() desde _ready() después de crear el mapa.

# ---------------------------------------------------------
# PIEZA 1: LA LISTA DE REGLAS (CONFIGURACIÓN)
# ---------------------------------------------------------

# Formato: ID_NODO_FIREWALL : [LISTA_DE_NODOS_A_BLOQUEAR]
var reglas_firewall = {
	# NODO 1 (Pasarela): Se conecta con 2 y 3.
	1: [2, 3],
	# NODO 2 (DNS): Se conecta con 1, 6 y 4.
	2: [1, 6, 4],
	# NODO 3 (Mensajería): Se conecta con 1, 4 y 5.
	3: [1, 4, 5],
	# NODO 4 (Firewall Server): Se conecta con 2, 3, 6 y 7.
	4: [2, 3, 6, 7],
	# NODO 5 (Repositorio): Se conecta con 3 y 7.
	5: [3, 7],
	# NODO 6 (AV Console): Se conecta con 2, 4 y 7.
	6: [2, 4, 7],
	# NODO 7 (Núcleo): Se conecta con 4, 5 y 6.
	7: [4, 5, 6] 
}
func _ready():
# ... (Igual que antes: crear mapa, calcular distancias, timer, spawn)
	crear_mapa_backend()         # Crea los nodos
	calcular_distancia_al_nucleo() # Calcula rutas
	spawn_malware_inicial()      # Pone los bichos
	
# Tu array que ahora contendrá los Malwares creados por spawn_malware_inicial()

func _process(delta):
	# Esto es crucial para que el virus se mueva (se ejecuta en cada frame)
	for virus in lista_malwares_activos:
		virus.procesar_ia(delta)
		
# --- LÓGICA DE MOVIMIENTO INTELIGENTE (BFS) ---
func calcular_distancia_al_nucleo():
# 1. Resetear
	for id in todos_los_nodos_por_id:
		todos_los_nodos_por_id[id].distancia_al_nucleo = -1

	# 2. Empezar desde el Núcleo (Nodo 7)
	var nucleo = todos_los_nodos_por_id[7]
	nucleo.distancia_al_nucleo = 0 
	var cola = [nucleo]

# 3. Calcular distancias hacia atrás
	while cola.size() > 0:
		var actual = cola.pop_front()
		for vecino in actual.vecinos:
			if vecino.distancia_al_nucleo == -1:
				vecino.distancia_al_nucleo = actual.distancia_al_nucleo + 1
				cola.append(vecino)
				print("Distancias calculadas. El mapa sabe dónde está el norte.")
				
# ---------------------------------------------------------
# PIEZA 2: EL MOTOR LÓGICO (EJECUCIÓN)
# ---------------------------------------------------------
# 1. Función para ACTIVAR MANUALMENTE 
func activar_firewall_manual(id_nodo_origen: int):
	# Usamos la configuración de reglas para saber qué caminos cortar
	if not reglas_firewall.has(id_nodo_origen): return

	var nodo_origen = todos_los_nodos_por_id[id_nodo_origen]
	var lista_objetivos = reglas_firewall[id_nodo_origen]

	for id_destino in lista_objetivos:
		var nodo_destino = todos_los_nodos_por_id[id_destino]
		nodo_origen.bloquear_vecino(nodo_destino) # Corta el cable específico

		print("FIREWALL MANUAL ACTIVO en Nodo " + str(id_nodo_origen))

# 2. Función para DESACTIVAR MANUALMENTE
func desactivar_firewall_manual(id_nodo_origen: int):
	if not reglas_firewall.has(id_nodo_origen): return

	var nodo_origen = todos_los_nodos_por_id[id_nodo_origen]
	var lista_objetivos = reglas_firewall[id_nodo_origen]

	for id_destino in lista_objetivos:
		var nodo_destino = todos_los_nodos_por_id[id_destino]
		nodo_origen.restaurar_vecino(nodo_destino) # Repara el cable específico

		print("FIREWALL MANUAL DESACTIVADO en Nodo " + str(id_nodo_origen))

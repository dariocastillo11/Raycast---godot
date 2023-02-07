extends Node2D
# Alumno:
# Día:
# Proyecto: Plataformero con RayCast

# Fondo Lava. Hecho.
# Portal.
# La animacion de muerte. Hecho.
# GameOver. Hecho.
# Hacer daño con "melee" y shoot. Hecho.
# Barra de Vida Zombies. Hecho.
# Enemigos extras.
# Los otros coleccionables. Hecho (casi).
# Check Point. Hecho.
# Variar los daños y los puntos.
# Hacer el HUD. Vamos a seguir después con los niveles.
# Agregar sonidos.
# Cambios de niveles.

# Estamos trabajando con al daño slash


var vida = 50
var puntos = 0
var nivel=0
var player=""
export (PackedScene) var Engrane
export (PackedScene) var Zombie
export (PackedScene) var Spit
export (PackedScene) var Shoot
export (PackedScene) var Bateria

func _ready():
	OS.center_window()
	puntos = Manager.puntos_global
	nivel= Manager.nivel_global
	player= Manager.player_global
	SF_instanciar_coleccionables()
	SF_instanciar_enemigos()
	SF_crear_lava()
	SF_HUD()
	pass


#func _process(delta):
#	pass

func SF_instanciar_coleccionables():
	for columna in range(100):
		for fila in range(19):
			var tile = $ContenedorTiles/TileMapColeccionables.get_cellv(Vector2(columna, fila))
			if tile == 0:
				$ContenedorTiles/TileMapColeccionables.set_cellv(Vector2(columna, fila), -1)
				var EngraneInstanciado = Engrane.instance()
				var posic_colec = Vector2(16 + (columna * 32), 16 + (fila * 32))
				EngraneInstanciado.position = posic_colec
				$ContenedorColeccionables.call_deferred("add_child", EngraneInstanciado)
			if tile == 1:
				$ContenedorTiles/TileMapColeccionables.set_cellv(Vector2(columna, fila), -1)
				var BateriaInstanciado = Bateria.instance()
				var posic_colec = Vector2(16 + (columna * 32), 16 + (fila * 32))
				BateriaInstanciado.position = posic_colec
				$ContenedorColeccionables.call_deferred("add_child", BateriaInstanciado)
	pass


func SF_instanciar_enemigos():
	for columna in range(100):
		for fila in range(19):
			var tile = $ContenedorTiles/TileMapEnemigos.get_cellv(Vector2(columna, fila))
			if tile == 0:
				$ContenedorTiles/TileMapEnemigos.set_cellv(Vector2(columna, fila), -1)
				var ZombieInstanciado = Zombie.instance()
				var posic_enemigo = Vector2(16 + (columna * 32), 16 + (fila * 32) )
				ZombieInstanciado.position = posic_enemigo
				$ContenedorEnemigos.call_deferred("add_child", ZombieInstanciado)
	pass


func SF_player_detectado(posic_enemigo, direccion):
	var SpitInstanciado = Spit.instance()
	posic_enemigo.y += 2
	SpitInstanciado.position = posic_enemigo
	$ContenedorSpits.call_deferred("add_child", SpitInstanciado)
	# Podemos pasar la direccion directamente a la variable.
	#SpitInstanciado.movimiento = direccion
	# O crear una función.
	SpitInstanciado.SF_direccion(direccion)
	pass


func _on_Player_tocado(valor):
	vida -= valor
	$HUD/BarraVida.value = vida
	# Hacer Game Over
	if vida <= 0:
		$Player.estado = "Dead"
		SF_gameover_ppal()
	pass


func _on_Player_colectado(valor):
	puntos += valor
	if valor == 10:
		vida = 100
	SF_HUD()
	pass


func _on_Player_disparado(posic_player, direccion):
	var ShootInstanciado = Shoot.instance()
	posic_player.y += 2
	posic_player.x += 20 * direccion
	ShootInstanciado.position = posic_player
	$ContenedorShoots.call_deferred("add_child", ShootInstanciado)
	ShootInstanciado.SF_direccion(direccion)
	pass


func SF_crear_lava():
	for columna in range(100):
		$ContenedorTiles/TileMapLava.set_cellv(Vector2(columna, 19), 0)
	pass


func _on_Player_lavado():
	vida = 0
	$HUD/BarraVida.value = vida
	# gAMEoVER = ?
	SF_gameover_ppal()
	pass

func SF_gameover_ppal():
	yield($Player/AnimatedPlayer, "animation_finished")
	vida = 75
	$HUD/BarraVida.value = vida
	pass


func SF_HUD():
	$HUD/Puntos.text = str(puntos)
	$HUD/Nivel.text = str(nivel)
	$HUD/Player.text=player
	$HUD/BarraVida.value = vida
	pass


func _on_Player_nivelado():
	nivel+=1
	SF_HUD()
	Manager.puntos_global=puntos
	Manager.nivel_global=nivel
	#cambiar escena
	get_tree().change_scene("res://Escenas/Niveles/Nivel_"+str(nivel)+".tscn")
	
	pass 

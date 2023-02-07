extends KinematicBody2D

signal tocado
signal colectado
signal disparado
signal lavado
signal nivelado

var velocidad_player = Vector2()
var movimiento = 0
var estado = "Idle"
var animacion = ""
var animacion_actual = ""
var posic_inic = Vector2()
var gravedad = 450
var posic_check = Vector2(100, 220)

const VELOCIDAD = 150
#const GRAVEDAD = 500


func _ready():
	set_physics_process(false)
	SF_intro()
	pass


func _physics_process(delta):
	
	match(estado):
		"Idle":
			movimiento = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
			if movimiento != 0:
				estado = "Run"
			elif Input.is_action_just_pressed("ui_accept"):
				velocidad_player.y = -200
				estado = "Jump"
			elif Input.is_action_just_pressed("ui_up"):
				$Melee/HitboxMelee.set_deferred("disabled", false)
				estado = "Melee"
			elif Input.is_action_just_pressed("ui_shoot"):
				emit_signal("disparado", position, $AnimatedPlayer.scale.x)
				estado = "Shoot"
		"Run":
			movimiento = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
			if movimiento == 0:
				estado = "Idle"
			elif Input.is_action_just_pressed("ui_accept"):
				velocidad_player.y = -200
				estado = "Jump"
			elif !is_on_floor():
				estado = "Caida"
			elif Input.is_action_just_pressed("ui_down"):
				posic_inic = position
				$HitboxSlide.set_deferred("disabled", false)
				$HitboxPlayer.set_deferred("disabled", true)
				estado = "Slide"
			elif Input.is_action_just_pressed("ui_shoot"):
				emit_signal("disparado", position, $AnimatedPlayer.scale.x)
				estado = "RunShoot"
		"Jump":
			movimiento = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
			if is_on_floor():
				estado = "Idle"
			elif Input.is_action_just_pressed("ui_accept"):
				velocidad_player.y = -200
				estado = "Jump2"
			elif Input.is_action_just_pressed("ui_up"):
				$Melee/HitboxMelee.set_deferred("disabled", false)
				estado = "JumpMelee"
			elif Input.is_action_just_pressed("ui_shoot"):
				emit_signal("disparado", position, $AnimatedPlayer.scale.x)
				estado = "JumpShoot"
			elif $AnimatedPlayer/RayCastPared.is_colliding():
				movimiento = 0
				gravedad = 15
				velocidad_player.y = 0
				estado = "Escalada"
				
		"Jump2":
			movimiento = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
			if is_on_floor():
				estado = "Idle"
			elif Input.is_action_just_pressed("ui_up"):
				$Melee/HitboxMelee.set_deferred("disabled", false)
				estado = "JumpMelee"
			elif Input.is_action_just_pressed("ui_shoot"):
				emit_signal("disparado", position, $AnimatedPlayer.scale.x)
				estado = "JumpShoot"
			elif $AnimatedPlayer/RayCastPared.is_colliding():
				movimiento = 0
				gravedad = 15
				velocidad_player.y = 0
				estado = "Escalada"
		"Caida":
			if is_on_floor():
				estado = "Idle"
			elif $AnimatedPlayer/RayCastPared.is_colliding():
				movimiento = 0
				gravedad = 15
				velocidad_player.y = 0
				estado = "Escalada"
		"Melee":
			yield($AnimatedPlayer, "animation_finished")
			$Melee/HitboxMelee.set_deferred("disabled", true)
			estado = "Idle"
		"JumpMelee":
			SF_mientras()
		"Shoot":
			if Input.is_action_just_pressed("ui_shoot"):
				emit_signal("disparado", position, $AnimatedPlayer.scale.x)
			yield($AnimatedPlayer, "animation_finished")
			estado = "Idle"
		"RunShoot":
			movimiento = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
			if movimiento == 0:
				estado = "Idle"
			elif Input.is_action_just_pressed("ui_shoot"):
				emit_signal("disparado", position, $AnimatedPlayer.scale.x)
			SF_mientras()
		"JumpShoot":
			if Input.is_action_just_pressed("ui_shoot"):
				emit_signal("disparado", position, $AnimatedPlayer.scale.x)
			SF_mientras()
		"Slide":
			var distancia = position.distance_to(posic_inic)
			if (distancia > 100) and !($AnimatedPlayer/RayCastTecho.is_colliding()):
				$HitboxPlayer.set_deferred("disabled", false)
				$HitboxSlide.set_deferred("disabled", true)
				estado = "Idle"
			elif !is_on_floor():
				$HitboxPlayer.set_deferred("disabled", false)
				$HitboxSlide.set_deferred("disabled", true)
				estado = "Caida"
			elif is_on_wall():
				$HitboxPlayer.set_deferred("disabled", false)
				$HitboxSlide.set_deferred("disabled", true)
				estado = "Idle"
		"Escalada":
			if !($AnimatedPlayer/RayCastPared.is_colliding()):
				gravedad = 500
				estado = "Caida"
				print("Caida")
			elif Input.is_action_just_pressed("ui_accept"):
				velocidad_player.y = -200
				gravedad = 500
				movimiento = -($AnimatedPlayer.scale.x)
				estado = "Jump"
		"Dead":
			SF_gameover()
		_:
			print("default")
			pass
	
	SF_animacion()
	
	velocidad_player.x = movimiento * VELOCIDAD
	velocidad_player.y += gravedad * delta
	velocidad_player = move_and_slide(velocidad_player, Vector2(0, -1))
	
	pass


func SF_animacion():
	animacion = estado
	if animacion != animacion_actual:
		$AnimatedPlayer.animation = animacion
		animacion_actual = animacion
	if movimiento != 0:
		$AnimatedPlayer.scale.x = movimiento
	pass


func _on_DetectorColisiones_body_entered(body):
	if body.is_in_group("Spit"):
		emit_signal("tocado",5)
		$AnimatedPlayer.modulate = Color(1, 0.5, 0.5, 0.8)
		$TimerTocado.start()
	if body.is_in_group("Engrane"):
		emit_signal("colectado", 1)
		body.SF_borrar()
	if body.is_in_group("Bateria"):
		emit_signal("colectado", 10)
		# Cambiar Check Point
		posic_check = position
		body.SF_borrar()
	if body.is_in_group("Lava"):
		emit_signal("lavado")
		estado = "Dead"
	pass


func _on_TimerTocado_timeout():
	$AnimatedPlayer.modulate = Color(1, 1, 1, 1)
	pass


func SF_mientras():
	yield($AnimatedPlayer, "animation_finished")
	$Melee/HitboxMelee.set_deferred("disabled", true)
	if is_on_floor():
		estado = "Idle"
	else:
		estado = "Caida"
	pass


func SF_gameover():
	set_physics_process(false)
	SF_animacion()
	yield($AnimatedPlayer, "animation_finished")
	position = posic_check
	estado = "Idle"
	set_physics_process(true)
	pass


func _on_DetectorColisiones_area_entered(area):
	if area.is_in_group("Slash"):
		emit_signal("tocado",20)
		$AnimatedPlayer.modulate = Color(1, 0.5, 0.5, 0.8)
		$TimerTocado.start()
	if area.is_in_group("Portal"):
		SF_portal()
	pass
func SF_portal():
	#vamos a desactivar el process
	set_physics_process(false)
	#iniciar la animacion de cierre del portal
	get_node("//root/Ppal/Portal/AnimatedPortal").animation="Cierre"
	#pasar el player a animacion de caida
	$AnimatedPlayer.animation="Caida"
	#Abducir al player
	$Tween.interpolate_property(self,"position",position,Vector2(495,220),2)
	$Tween.start()
	#Desvanecerlo
	yield($Tween,"tween_completed")
	$Tween.interpolate_property($AnimatedPlayer,"modulate",Color(1, 1, 1, 1),Color(1, 1, 1, 0),2)
	$Tween.start()
	#cambiar de nivel
	emit_signal("nivelado")
	
	pass
func SF_intro():
	$Camera2D.zoom=Vector2(0.5, 0.5)
	var PortalEntrada=get_node("//root/Ppal/PortalEntrada")
	var posic_portal_entrada= PortalEntrada.position
	$AnimatedPlayer.animation="Caida" 
	position =posic_portal_entrada
	$Tween.interpolate_property($AnimatedPlayer,"modulate",Color(1, 1, 1, 0),Color(1, 1, 1, 1),1)
	$Tween.start()
	yield($Tween,"tween_completed")
	get_node("//root/Ppal/PortalEntrada/AnimatedPortal").animation="Apertura"
	$Tween.interpolate_property(self,"position",posic_portal_entrada,posic_check,1)
	$Tween.interpolate_property($Camera2D,"zoom",Vector2(0.5,0.5),Vector2(1,1),1)
	$Tween.start()
	yield($Tween,"tween_completed")
	set_physics_process(true)
	pass

extends KinematicBody2D

var velocidad_esqueleto = Vector2()
var movimiento = 1
var spit = true
var vida = 100
var velocidad = 60

const GRAVEDAD = 500


func _ready():
	pass


func _physics_process(delta):
	if $AnimatedEsqueleto/RayCastPared.is_colliding():
		SF_flip()
	if (is_on_floor()) and !($AnimatedEsqueleto/RayCastSuelo.is_colliding()):
		SF_flip()
	if $AnimatedEsqueleto/RayCastPlayerFlip.is_colliding():
		SF_flip()
#	if (spit) and ($AnimatedEsqueleto/RayCastPlayer.is_colliding()):
#		get_node("//root/Ppal").SF_player_detectado(position, movimiento)
#		spit = false
#		$TimerSpit.start()
	if $AnimatedEsqueleto/RayCastPlayer.is_colliding():
		$AnimatedEsqueleto.animation = "Slash"
		if $AnimatedEsqueleto.frame==4:
			$AnimatedEsqueleto/Slash/HitboxSlash.set_deferred("disabled", false)
		else:
			$AnimatedEsqueleto/Slash/HitboxSlash.set_deferred("disabled", true)
		movimiento = 0
	else:
		$AnimatedEsqueleto.animation = "Run"
		movimiento = $AnimatedEsqueleto.scale.x
		velocidad = 60
		$AnimatedEsqueleto.speed_scale = 1
		$AnimatedEsqueleto/Slash/HitboxSlash.set_deferred("disabled", true)
	if $AnimatedEsqueleto/RayCastLejano.is_colliding():
		velocidad = 120
		$AnimatedEsqueleto.speed_scale = 1.5
	
	velocidad_esqueleto.x = movimiento * velocidad
	velocidad_esqueleto.y += GRAVEDAD * delta
	velocidad_esqueleto = move_and_slide(velocidad_esqueleto, Vector2(0, -1))
	pass


func SF_flip():
	if movimiento != 0:
		movimiento *= -1
		$AnimatedEsqueleto.scale.x = movimiento
	pass


func _on_TimerSpit_timeout():
	spit = true
	pass


func _on_DetectorColisiones_body_entered(body):
	if body.is_in_group("Shoot"):
		vida -= 25
		$BarraVida.value = vida
		$AnimatedEsqueleto.modulate = Color(0.5, 1, 0.5, 0.8)
		$TimerTocado.start()
		# Borrar Bala
		body.SF_borrar()
	if vida <= 0:
		SF_dead()
	pass


func _on_TimerTocado_timeout():
	$AnimatedEsqueleto.modulate = Color(1, 1, 1, 1)
	pass

func SF_dead():
	# Que pare de moverse.
	set_physics_process(false)
	# Que se active la animación Dead.
	$AnimatedEsqueleto.animation = "Dead"
	$AnimatedEsqueleto.modulate = Color(0.5, 1, 0.5, 0.8)
	$TimerTocado.stop()
	# Que desasparezca.
	yield($AnimatedEsqueleto, "animation_finished")
	$BarraVida.visible = false
	$Tween.interpolate_property($AnimatedEsqueleto,"modulate", Color(0.5, 1, 0.5, 0.8), Color(0.5, 1, 0.5, 0), 2)
	$Tween.start()
	yield($Tween, "tween_completed")
	call_deferred("queue_free")
	pass


func _on_DetectorColisiones_area_entered(area):
	if area.is_in_group("Melee"):
		vida -= 34
		$BarraVida.value = vida
		$AnimatedEsqueleto.modulate = Color(0.5, 1, 0.5, 0.8)
		$TimerTocado.start()
	if vida <= 0:
		SF_dead()
	pass

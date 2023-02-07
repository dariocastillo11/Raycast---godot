extends KinematicBody2D

var velocidad_zombie = Vector2()
var movimiento = 1
var spit = true
var vida = 100

const VELOCIDAD = 40
const GRAVEDAD = 500


func _ready():
	pass


func _physics_process(delta):
	if $AnimatedZombie/RayCastPared.is_colliding():
		SF_flip()
	if (is_on_floor()) and !($AnimatedZombie/RayCastSuelo.is_colliding()):
		SF_flip()
	if (spit) and ($AnimatedZombie/RayCastPlayer.is_colliding()):
		get_node("//root/Ppal").SF_player_detectado(position, movimiento)
		spit = false
		$TimerSpit.start()
	velocidad_zombie.x = movimiento * VELOCIDAD
	velocidad_zombie.y += GRAVEDAD * delta
	velocidad_zombie = move_and_slide(velocidad_zombie, Vector2(0, -1))
	pass


func SF_flip():
	movimiento *= -1
	$AnimatedZombie.scale.x = movimiento
	pass


func _on_TimerSpit_timeout():
	spit = true
	pass


func _on_DetectorColisiones_body_entered(body):
	if body.is_in_group("Shoot"):
		vida -= 25
		$BarraVida.value = vida
		$AnimatedZombie.modulate = Color(0.5, 1, 0.5, 0.8)
		$TimerTocado.start()
		# Borrar Bala
		body.SF_borrar()
	if vida <= 0:
		SF_dead()
	pass


func _on_TimerTocado_timeout():
	$AnimatedZombie.modulate = Color(1, 1, 1, 1)
	pass

func SF_dead():
	# Que pare de moverse.
	set_physics_process(false)
	# Que se active la animación Dead.
	$AnimatedZombie.animation = "Dead"
	$AnimatedZombie.modulate = Color(0.5, 1, 0.5, 0.8)
	$TimerTocado.stop()
	# Que desasparezca.
	yield($AnimatedZombie, "animation_finished")
	$BarraVida.visible = false
	$Tween.interpolate_property($AnimatedZombie,"modulate", Color(0.5, 1, 0.5, 0.8), Color(0.5, 1, 0.5, 0), 2)
	$Tween.start()
	yield($Tween, "tween_completed")
	call_deferred("queue_free")
	pass


func _on_DetectorColisiones_area_entered(area):
	if area.is_in_group("Melee"):
		vida -= 34
		$BarraVida.value = vida
		$AnimatedZombie.modulate = Color(0.5, 1, 0.5, 0.8)
		$TimerTocado.start()
	if vida <= 0:
		SF_dead()
	pass

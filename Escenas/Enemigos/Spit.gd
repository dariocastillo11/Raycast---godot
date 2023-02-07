extends KinematicBody2D

var velocidad_spit = Vector2(0, -150)
var movimiento = 1
var seno = 0

const VELOCIDAD = 150
const GRAVEDAD = 500

func _ready():
	pass


func _physics_process(delta):
	#SF_movimiento()
	#SF_animar()
	velocidad_spit.x = movimiento * VELOCIDAD
	velocidad_spit.y += GRAVEDAD * delta * 0.5
#	seno += 500000
#	velocidad_spit.y += 200 * sin(seno)
	velocidad_spit = move_and_slide(velocidad_spit, Vector2(0, -1))
	if (is_on_floor()) or (is_on_wall()):
		SF_borrar()
	pass

func SF_direccion(direccion):
	movimiento = direccion
	pass


func SF_borrar():
	call_deferred("queue_free")
	pass


func _on_NotificadorPantalla_screen_exited():
	SF_borrar()
	pass

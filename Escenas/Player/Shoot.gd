extends KinematicBody2D

var velocidad_shoot = Vector2()
var movimiento = 1

const VELOCIDAD = 300


func _ready():
	pass


func _physics_process(_delta):
	velocidad_shoot.x = movimiento * VELOCIDAD
	velocidad_shoot = move_and_slide(velocidad_shoot, Vector2(0, -1))
	
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

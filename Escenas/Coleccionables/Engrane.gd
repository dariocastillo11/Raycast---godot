extends StaticBody2D


func _ready():
	pass


#func _process(delta):
#	pass


func SF_borrar():
	call_deferred("queue_free")
	pass

extends Camera2D

onready var player = get_node("../Player")

var acceleration = 7

func _physics_process(delta):
	global_transform.origin = lerp(global_transform.origin, player.global_transform.origin, delta*acceleration)

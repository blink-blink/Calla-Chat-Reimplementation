extends Camera2D

onready var player

var acceleration = 4
var zoomAmount = Vector2(0.05, 0.05)
var targetZoom
var zoomAcceleration = 0.5
var maxZoom = 1

func _ready():
	# try getting player
	player = get_node("../ControlledPlayer")
	if player:
		# setup camera to smoothly follow target
		global_transform.origin = player.global_transform.origin
	else:
		# player not found, disable camera until its set
		set_process(false)
	self.smoothing_enabled = true
	self.smoothing_speed = acceleration
	targetZoom = self.zoom

func set_player(instance):
	player = instance
	if player:
		set_process(true)
	
func _process(delta):
	global_transform.origin = player.global_transform.origin
	self.zoom = self.zoom.move_toward(targetZoom, zoomAcceleration*delta)

func _input(event):
	# camera zoom logic
	if event.is_action_pressed("scroll_down"):
		targetZoom += zoomAmount
		targetZoom = targetZoom.abs()
		targetZoom = targetZoom.clamped(maxZoom)
	if event.is_action_pressed("scroll_up"):
		targetZoom -= zoomAmount
		if targetZoom.length_squared() < 0.01:
			targetZoom = Vector2(0.1,0.1)

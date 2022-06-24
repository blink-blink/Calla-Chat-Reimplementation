extends Camera2D

onready var player = get_node("../Player")

var acceleration = 4
var zoomAmount = Vector2(0.05, 0.05)
var targetZoom
var zoomAcceleration = 0.5
var maxZoom = 1

func _ready():
	global_transform.origin = player.global_transform.origin
	self.smoothing_enabled = true
	self.smoothing_speed = acceleration
	targetZoom = self.zoom

func _process(delta):
	global_transform.origin = player.global_transform.origin
	self.zoom = self.zoom.move_toward(targetZoom, zoomAcceleration*delta)

func _input(event):
	if event.is_action_pressed("scroll_up"):
		targetZoom += zoomAmount
		targetZoom = targetZoom.abs()
		targetZoom = targetZoom.clamped(maxZoom)
	if event.is_action_pressed("scroll_down"):
		targetZoom -= zoomAmount
		if targetZoom.length_squared() < 0.01:
			targetZoom = Vector2(0.1,0.1)

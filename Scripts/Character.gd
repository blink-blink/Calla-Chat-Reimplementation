extends KinematicBody2D

class_name Character # this class is inherited by controlled player and peer player

signal tick

const CLIENT_TICK_RATE =  0.2
const SERVER_TICK_RATE = 0.2 # set this to the server's tick rate, or request tickrate from server
var tick = 0

onready var sprite = $AnimatedSprite
onready var speechbubble = $SpeechBubble

var username
var avatar : int = 0

var vel: Vector2
var dir: Vector2
var curangle

var Navigation2d: Navigation2D
var path: Array = [] #nav path

var move_speed = 100

func _ready():
	# grab navmesh
	if get_tree().has_group("MapNavigation"):
		Navigation2d = get_tree().get_nodes_in_group("MapNavigation")[0]

func control(delta): # overwritten to have different implementations based on whether its controlled player or peer player
	return false	 # should return true if player controlled, false otherwise

func generate_path(start: Vector2, end: Vector2):
	path = Navigation2d.get_simple_path(start, end, true)

func traverse_path(delta):
	if path.size() > 0:
		vel = global_position.direction_to(path[0])
		
		#if reached point then pop
		if global_position.distance_to(path[0]) <= delta*move_speed:
			path.pop_front()

#set current navmesh
func set_navigation(nav: Navigation2D):
	Navigation2d = nav

func _physics_process(delta):
	# do implementation of either controlledplayer or peerplayer of movement
	var is_local_player = control(delta) 
	
	# animate sprite
	animate()
	
	# tick
	tick += delta
	if tick >= CLIENT_TICK_RATE:
		tick = 0
		if is_local_player:
			send_position()
		else:
			emit_signal("tick")

func send_position():
	Multiplayer.update_player_position(self.global_position)

func animate():
	# sprite animations
	if vel.length_squared() < 0.01:
		# idle frame
		sprite.set_frame(0)
		sprite.stop()
	else:
		# change animation direction based on vel angle
		curangle = vel.angle()
		if curangle > -PI/4 and curangle < PI/4:
			sprite.play("run right")
		elif (curangle > PI/4 or is_equal_approx(curangle,PI/4)) and (curangle < 3*PI/4 or is_equal_approx(curangle,3*PI/4)):
			sprite.play("run down")
		elif (curangle > -3*PI/4 or is_equal_approx(curangle,-3*PI/4)) and (curangle < -PI/4 or is_equal_approx(curangle,-PI/4)):
			sprite.play("run up")
		else:
			sprite.play("run left")

func emote(emote):
	speechbubble.startEmote(emote)

func set_username(name):
	var label = get_node("Username")
	label.text = name

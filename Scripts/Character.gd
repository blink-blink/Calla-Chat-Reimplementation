extends KinematicBody2D

class_name Character

const NETWORK_TICK_RATE =  0.03
var tick = 0

onready var sprite = $AnimatedSprite

var vel: Vector2
var dir: Vector2
var curangle

var is_moving = false

var move_speed = 100

func _ready():
	pass

func player_control(delta): # overwritten if character is player
	pass

func _physics_process(delta):
	var is_local_player = player_control(delta)
	
	# move based on vel
	vel = vel.normalized()
	vel = move_and_slide(vel*move_speed)
	
	# sprite animations
	if vel.length_squared() < 0.01:
		if is_moving:
			is_moving = false
		
		# idle frame
		sprite.set_frame(0)
		sprite.stop()
	else:
		if not is_moving:
			is_moving = true
		
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
	
	if tick <= NETWORK_TICK_RATE:
		tick += delta
	else:
		tick = 0
		if is_local_player:
			send_world_state()

func start_emote(emote_type: String):
	show_emote(emote_type)
	Server.send_emote_request(emote_type)

func show_emote(emote_type: String):
	$SpeechBubble.show_emote(emote_type)

func send_world_state():
	Server.send_player_state(define_player_state())

func define_player_state() -> Dictionary:
	var player_state = {
		#time
		"T": OS.get_system_time_msecs(),
		
		#pos
		"P": self.position,
		
		#vel
		"V": self.vel,
		
		#curangle
		"C": self.curangle,
		
		#ismoving state
		"I": self.is_moving
	}
	
	return player_state

func update_player_state(player_state):
	
	#interpolate here (use tween)
	
	#pos
	self.position = player_state["P"]
	#vel
	self.vel = player_state["V"]
	#curangle
	self.curangle = player_state["C"]
	#ismoving state
	self.is_moving = player_state["I"]

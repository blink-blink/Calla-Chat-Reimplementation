extends KinematicBody2D

class_name Character

const CLIENT_TICK_RATE =  1.0/45
const SERVER_TICK_RATE = 1.0/20	 # set this to the server's tick rate, or request tickrate from server
var tick = 0

onready var sprite = $AnimatedSprite
onready var tween: Tween

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
	
	# move based on vel if tween is not active
	if !tween or not tween.is_active():
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
	
	tick += delta
	if tick >= CLIENT_TICK_RATE:
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
	if !tween:
		print("tween created")
		tween = Tween.new()
		self.add_child(tween)
	
	# pos
	# if distance between position too high then teleport
	if (player_state["P"] - position).length() >= move_speed*SERVER_TICK_RATE*3:
		self.position = player_state["P"]
	else:
		tween.interpolate_property(self, "position", position, player_state["P"], SERVER_TICK_RATE)
		tween.start()
	#vel
	self.vel = player_state["V"]
	#curangle
	self.curangle = player_state["C"]
	#ismoving state
	self.is_moving = player_state["I"]

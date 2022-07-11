extends KinematicBody2D

onready var sprite = $AnimatedSprite

var username
var avatar

var vel: Vector2
var dir: Vector2

var move_up = false
var move_down = false
var move_left = false
var move_right = false
var teleported = false

var Navigation2d: Navigation2D
var path: Array = [] #nav path

var move_speed = 100

func _ready():
	if get_tree().has_group("MapNavigation"):
		Navigation2d = get_tree().get_nodes_in_group("MapNavigation")[0]
	Multiplayer.register_main_instance(self)

func player_arrow_controlled():
	var is_controlled = false
	
	vel = Vector2()
	if Input.is_action_pressed("up"):
		vel.y -= 1
		is_controlled = true
	if Input.is_action_pressed("down"):
		vel.y += 1
		is_controlled = true
	if Input.is_action_pressed("left"):
		vel.x -= 1
		is_controlled = true
	if Input.is_action_pressed("right"):
		vel.x += 1
		is_controlled = true
	
	if is_controlled:
		path.clear()
		return true
	return false

func _unhandled_input(event):
	if event.is_action_pressed("mouse_right"):
		if event.get_shift() == true:
			# teleport movement
			self.global_position = get_global_mouse_position()
			teleported = true
			path.clear()
		else:
			# generate path on click
			generate_path(global_position, get_global_mouse_position())

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
	if not player_arrow_controlled():
		# traverse path if any
		traverse_path(delta)
	
	# move based on vel
	vel = vel.normalized()
	vel = move_and_slide(vel*move_speed)
	
	# send position update
	if vel.length_squared() > 0 or teleported == true:
		Multiplayer.update_player_position(self.global_position)
	
	# sprite animations
	if vel.length_squared() < 0.01:
		# idle frame
		sprite.set_frame(0)
		sprite.stop()
	else:
		# change animation direction based on vel angle
		var curangle = vel.angle()
		if curangle > -PI/4 and curangle < PI/4:
			sprite.play("run right")
		elif (curangle > PI/4 or is_equal_approx(curangle,PI/4)) and (curangle < 3*PI/4 or is_equal_approx(curangle,3*PI/4)):
			sprite.play("run down")
		elif (curangle > -3*PI/4 or is_equal_approx(curangle,-3*PI/4)) and (curangle < -PI/4 or is_equal_approx(curangle,-PI/4)):
			sprite.play("run up")
		else:
			sprite.play("run left")
	
	# reset teleported boolean
	teleported = false

func update_position():
	Multiplayer.update_player_position(self.global_position)

func set_username(name):
	var label = get_node("Username")
	label.text = name

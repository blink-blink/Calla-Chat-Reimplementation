extends Character

var move_up = false
var move_down = false
var move_left = false
var move_right = false
var teleported = false

func _ready():
	Multiplayer.register_main_instance(self)
	var index = 1
	# connect pressed signals of emote buttons to startEmote function
	for button in get_tree().get_nodes_in_group("emotebuttons"):
		button.connect("pressed", speechbubble, "startEmote", [index])
		index += 1

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

func control(delta):
	if not player_arrow_controlled():
		# traverse path if any
		traverse_path(delta)
	
	# move based on vel
	vel = vel.normalized()
	vel = move_and_slide(vel*move_speed)
	
	# reset teleported boolean
	teleported = false
	return true

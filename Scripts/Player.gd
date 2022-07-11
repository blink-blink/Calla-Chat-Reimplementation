extends Character

var Navigation2d: Navigation2D
var path: Array = [] #nav path

func _ready():
	#connect to server (test)
	Server.set_local_player(self)
	Server.connect_to_server()
	
	if get_tree().has_group("MapNavigation"):
		Navigation2d = get_tree().get_nodes_in_group("MapNavigation")[0]

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

func player_control(delta) -> bool:
	if not player_arrow_controlled():
		# traverse path if any
		traverse_path(delta)
	return true

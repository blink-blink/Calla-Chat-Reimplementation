extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var all_users: Dictionary = {}
var map_config: Dictionary = {}
# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	start_calla_meeting()
	var map_class = load("res://Scenes/Map1.tscn")	
	var map_object = map_class.instance()
	self.add_child(map_object)

func start_calla_meeting():
	var map_config_file = File.new()
	if map_config_file.file_exists("user://map_configuration.json"):
		map_config_file.open("user://map_configuration.json",File.READ)
		var map_config = parse_json(map_config_file.get_line())
		map_config_file.close()
	else:
		map_config["x_size"] = 100.0
		map_config["y_size"] = 100.0
		map_config["obstacles"] = Array()
		
	var command_and_control = NetworkedMultiplayerENet.new()
	command_and_control.create_server(22552,200)
	get_tree().network_peer = command_and_control
	get_tree().connect("network_peer_connected",self,"spawn_new_player")
	get_tree().connect("network_peer_disconnected",self,"despawn_player")


func spawn_new_player(id: int):
	pass
	
func despawn_player(id: int):
	all_users.erase(id)

remote func register_client(client_id: int, client_username: String, client_avatar: int):
	var x_position: float = 0
	var y_position: float = 0
	all_users[client_id] = {"username": client_username,"x": x_position, "y": y_position, "avatar": client_avatar}
	
	
remote func update_client_position(client_id: int, new_x: float, new_y: float):
	all_users[client_id]["x"] = new_x
	all_users[client_id]["y"] = new_y

remote func disconnect_me(id: int):
	emit_signal("network_peer_disconnected",id)
	pass

func dial_received(id: int):
	pass	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

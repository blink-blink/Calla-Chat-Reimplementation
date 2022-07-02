extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var usernames: Dictionary = {}
# Called when the node enters the scene tree for the first time.
func _ready():
	start_calla_meeting()
	var map_class = load("res://Scenes/Map1.tscn")	
	var map_object = map_class.instance()
	self.add_child(map_object)

func start_calla_meeting():
	var command_and_control = NetworkedMultiplayerENet.new()
	command_and_control.create_server(22552,200)
	get_tree().network_peer = command_and_control
	get_tree().connect("network_peer_connected",self,"spawn_new_player")
	get_tree().connect("network_peer_disconnected",self,"despawn_player")

func spawn_new_player(id: int):
	usernames[id] = get_username(id)
	
func despawn_player(id: int):
	usernames.erase(id)
	
func get_username(id: int):
	pass
	
remote func update_client_position(client_id: int, new_x: float, new_y: float):
	pass

remote func disconnect_me(id: int):
	emit_signal("network_peer_disconnected",id)
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

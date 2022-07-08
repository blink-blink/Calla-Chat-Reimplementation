extends Node


var mainplayer
var usernames: Dictionary = {}
var serverIP = "192.168.195.1"
var serverPort = 22552

func _ready():
	pass

func start_client():
	var peer = NetworkedMultiplayerENet.new()
	peer.create_client(serverIP, serverPort)
	get_tree().network_peer = peer

func spawn_new_player(id: int):
	usernames[id] = get_username(id)
	
func despawn_player(id: int):
	usernames.erase(id)
	
func get_username(id: int):
	pass
	
remote func set_all_user_positions(user_positions: Dictionary):
	pass

remote func disconnect_me(id: int):
	emit_signal("network_peer_disconnected",id)
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

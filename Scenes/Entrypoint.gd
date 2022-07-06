extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var position_lock: Mutex = Mutex.new()
var user_positions: Dictionary = {}
var usernames: Dictionary ={}
var user_avatars: Dictionary ={}

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	
	
func start_calla_meeting(hostname: String,host_avatar: int):
	user_positions[-1] = {"x":0,"y":0}
	usernames[-1] = hostname
	user_avatars[-1] = host_avatar
	var command_and_control = NetworkedMultiplayerENet.new()
	command_and_control.create_server(22552,200)
	get_tree().network_peer = command_and_control
	get_tree().connect("network_peer_disconnected",self,"despawn_player")
	$synchronizer.start()


func despawn_player(id: int):
	position_lock.lock()
	user_positions.erase(id)
	for user_id in user_positions.keys():
		rpc_id(user_id,"disconnect_me",id)
	position_lock.unlock()
	usernames.erase(id)
	user_avatars.erase(id)
	
	
remote func register_client(client_id: int, client_username: String, client_avatar: int, client_x: float, client_y: float):
	position_lock.lock()
	user_positions[client_id] = {"x": client_x, "y": client_y}
	usernames[client_id] = client_username
	user_avatars[client_id] = client_avatar
	rpc_unreliable_id(client_id, "set_all_user_positions",user_positions)
	rpc_id(client_id,"set_all_usernames",usernames)
	rpc_id(client_id,"set_all_avatars",user_avatars)
	for user_id in user_positions.keys():
		if client_id != user_id:
			rpc_id(user_id, "add_new_user", client_username, client_avatar)
	position_lock.unlock()
	
remote func update_client_position(client_id: int, new_x: float, new_y: float):
	position_lock.lock()
	user_positions[client_id]["x"] = new_x
	user_positions[client_id]["y"] = new_y
	position_lock.unlock()
	
remote func set_client_emote(client_id: int, emote: int):
	for user_id in user_avatars.keys():
		if user_id != client_id:
			rpc_id(user_id,"set_client_emote",client_id,emote)
	
remote func disconnect_me(id: int):
	emit_signal("network_peer_disconnected",id)
	pass

func dial_received(id: int):
	pass	

func synchronize_user_positions():
	position_lock.lock()
	for user_id in user_positions.keys():
		rpc_unreliable_id(user_id, "set_all_user_positions",user_positions)
	position_lock.unlock()
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func stop_calla_meeting():
	$synchronizer.stop()
	get_tree().network_peer = null 

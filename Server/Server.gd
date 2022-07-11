extends Node

#network
var network = NetworkedMultiplayerENet.new()
var port = 1909
var max_players = 200

#collection
var player_state_collection = {}
var world_state

func _ready():
	start_server()

func start_server():
	network.create_server(port, max_players)
	get_tree().set_network_peer(network)
	print("Server Started")
	
	#signals
	network.connect("peer_connected", self, "_peer_connected")
	network.connect("peer_disconnected", self, "_peer_disconnected")

func _peer_connected(player_id):
	print("User ",player_id," connected")

func _peer_disconnected(player_id):
	print("User ",player_id," disconnected")
	player_state_collection.erase(player_id)
	rpc_id(0, "despawn_player", player_id)

# State Processing

# use _physics_process for constant delta, we set physics fps
# for the server to 20 (we send world_state 20 times a second)
func _physics_process(delta):
	#print("psc: ",player_state_collection)
	#if no players then return
	if player_state_collection.empty():
		return
	
	# set world state = current player state collection 
	world_state = player_state_collection.duplicate(true)
	
	# minimize bandwidth
	for player in world_state.keys():
		#remove player_state time "T"
		world_state[player].erase("T")
	
	#set world_state time 
	world_state["T"] = OS.get_system_time_msecs()
	
	#verification, anti-cheat lol or anything else if any
	
	#rpc for sending world state, send to 0 means it sends to everyone
	rpc_unreliable_id(0, "recieve_world_state", world_state)

func update_player_state_collection(player_id, player_state):
	# update player_state_collection
	if player_state_collection.has(player_id): 
		if player_state["T"] > player_state_collection[player_id]["T"]: # if latest state
			player_state_collection[player_id] = player_state 
	else:
		player_state_collection[player_id] = player_state 

remote func recieve_player_spawn_request(player_state):
	print("player spawn request recieved")
	var player_id = get_tree().get_rpc_sender_id()
	
	update_player_state_collection(player_id, player_state)
	rpc_id(0, "spawn_new_player", player_id, player_state)

remote func recieve_player_state(player_state):
	var player_id = get_tree().get_rpc_sender_id()
	
	update_player_state_collection(player_id, player_state)

remote func recieve_emote_request(emote_type: String):
	print("emote request recieved")
	var player_id = get_tree().get_rpc_sender_id()
	
	# send emote request to other players
	rpc_id(0, "recieve_emote_request", player_id, emote_type)
	

extends Node

var network = NetworkedMultiplayerENet.new()
var ip = "192.168.193.135" #change this to server ip
var port = 1909

var local_player: Character

func _ready():
	pass

func set_local_player(player: Character):
	local_player = player

func connect_to_server():
	network.create_client(ip, port)
	get_tree().set_network_peer(network)
	
	#signals
	network.connect("connection_failed", self, "_connection_failed")
	network.connect("connection_succeeded", self, "_connection_succeded")

func _connection_failed():
	print("connection failed")

func _connection_succeded():
	print("connection succeded")
	
	# request spawn player
	rpc_id(1, "recieve_player_spawn_request", local_player.define_player_state())

func send_player_state(player_state):
	rpc_unreliable_id(1,"recieve_player_state", player_state)

func send_emote_request(emote_type: String):
	rpc_id(1, "recieve_emote_request", emote_type)


# rpc
remote func recieve_emote_request(player_id, emote_type: String):
	get_node("/root/Map").start_emote_for_player(player_id, emote_type)

remote func recieve_world_state(world_state):
	#print("world state recieved")
	get_node("/root/Map").update_world_state(world_state)

remote func spawn_new_player(player_id, player_state):
	get_node("/root/Map").spawn_new_player(player_id, player_state)

remote func despawn_player(player_id):
	get_node("/root/Map").despawn_player(player_id)

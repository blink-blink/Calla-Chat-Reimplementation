extends Node


var playerinstances = {}
var usernames: Dictionary = {}
var serverIP = "192.168.195.1"
var serverPort = 22552
var uniqueID: int
var mainplayerusername: String

func _ready():
	get_tree().connect("connected_to_server", self, "connection_success")
	get_tree().connect("connection_failed", self, "connection_failure")
	get_tree().connect("server_disconnected", self, "disconnected")
	pass

func start_client(username):
	# connect to server
	var peer = NetworkedMultiplayerENet.new()
	peer.create_client(serverIP, serverPort)
	get_tree().network_peer = peer
	mainplayerusername = username
	# debug
	debug_conn_success()
	
func register_main_instance(instance):
	# main instance is assumed to already be loaded with the map
	playerinstances[uniqueID] = instance
	instance.set_username(mainplayerusername)
	
func create_peer_instance(ID):
	# Grab YSort and add peer instance as child of YSort
	var ysort = get_tree().get_node("YSort")
	var instance = Resources.nodes["PeerPlayer"]
	ysort.add_child(instance)
	playerinstances[ID] = instance
	
func debug_conn_success():
	# debug function to mimic getting a successful connection	
	uniqueID = get_tree().get_network_unique_id()
	get_tree().change_scene_to(Resources.scenes["map1"])

func connection_success():
	uniqueID = get_tree().get_network_unique_id()
	get_tree().change_scene_to(Resources.scenes["map1"])

func connection_failure():
	print("Connection unsuccessful")
	pass
	
func initiate_disconnect():
	rpc("disconnect_me", uniqueID)
	
func disconnected():
	print("Disconnected")
	pass

func update_player_position(position: Vector2):
	rpc_unreliable("update_client_position", uniqueID, position.x, position.y)

func send_emote(emoteint: int):
	rpc("set_client_emote", uniqueID, emoteint)
	
remote func disconnect_me(id):
	if playerinstances.has(id):
		# delete instance from dictionary and scene
		playerinstances[id].queue_free()
		playerinstances.erase(id)

remote func set_all_user_positions(positions: Dictionary):
	for user in positions.keys():
		if user == uniqueID:
			# skip own position
			continue
		if playerinstances.has(user):
			playerinstances[user].set_global_position(Vector2(positions[user]["x"],positions[user]["y"]))
		else:
			# add instance spawning code here
			continue

remote func set_all_usernames(usernames: Dictionary):
	pass

remote func set_all_avatars(avatars: Dictionary):
	pass

remote func add_new_user(userid: int, username: String, avatar: int):
	create_peer_instance(userid)

remote func set_client_emote(userid: int, emote: int):
	if playerinstances.has(userid):
		var target = playerinstances[userid]
		var speech = target.get_node("SpeechBubble")
		speech.startEmote(emote)

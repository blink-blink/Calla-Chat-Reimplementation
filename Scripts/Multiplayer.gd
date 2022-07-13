extends Node

var playerinstances = {} # keeps track of all player instances in the map
var usernames: Dictionary = {}
var serverIP = "192.168.195.1"
var serverPort = 22552
var uniqueID: int # our rpc id
var mainplayerusername: String # our username
var curtimestamp = -1 # timestamp for position updates
const CLIENT_TICK_RATE =  1.0/45
const SERVER_TICK_RATE = 1.0/20
var tick = 0 

func _ready():
	get_tree().connect("connected_to_server", self, "connection_success")
	get_tree().connect("connection_failed", self, "connection_failure")
	get_tree().connect("server_disconnected", self, "disconnected")

func start_client(username):
	# connect to server
	var peer = NetworkedMultiplayerENet.new()
	peer.create_client(serverIP, serverPort)
	get_tree().network_peer = peer
	mainplayerusername = username
	
	# debug ------------------------------------------------------------------------------
	# debug_conn_success() # IMPORTANT - REMOVE WHEN TESTING ACTUAL MULTIPLAYER CONNECTIVITY
	# debug ------------------------------------------------------------------------------
	
func register_main_instance(instance):
	# main instance is assumed to already be loaded with the map
	playerinstances[uniqueID] = instance
	instance.set_username(mainplayerusername)
	rpc("register_client", mainplayerusername, instance.avatar, instance.global_position.x, instance.global_position.y)
	
func create_peer_instance(ID, username = "user", avatar = 0):
	# Grab YSort and add peer instance as child of YSort
	var ysort = get_node("../Map1/YSort")
	var instance = Resources.nodes["PeerPlayer"].instance()
	ysort.add_child(instance)
	instance.name = str(ID)
	instance.set_username(username)
	playerinstances[ID] = instance
	
func debug_conn_success():
	# debug function to mimic getting a successful connection	
	uniqueID = get_tree().get_network_unique_id()
	get_tree().change_scene_to(Resources.scenes["map1"])

func connection_success():
	# on successful connection, load the map
	uniqueID = get_tree().get_network_unique_id()
	get_tree().change_scene_to(Resources.scenes["map1"])

func connection_failure():
	print("Connection unsuccessful")
	
func initiate_disconnect():
	rpc("disconnect_me")
	
func disconnected():
	print("Disconnected")

func update_player_position(position: Vector2):
	rpc_unreliable("update_client_position", position.x, position.y, OS.get_system_time_msecs())

func send_emote(emoteint: int):
	rpc("set_client_emote", uniqueID, emoteint)
	
remote func disconnect_me(id):
	if playerinstances.has(id):
		# delete instance from dictionary and scene
		playerinstances[id].queue_free()
		playerinstances.erase(id)

remote func set_all_user_positions(positions: Dictionary, timestamp: int):
	if timestamp < curtimestamp:
		# reject out of order packets
		return
	for user in positions.keys():
		if user == uniqueID:
			# skip own position
			continue
		if not playerinstances.has(user):
			create_peer_instance(user)
		playerinstances[user].update_player(Vector2(positions[user]["x"],positions[user]["y"]))
	curtimestamp = timestamp

remote func set_all_usernames(usernames: Dictionary):
	for user in usernames.keys():
		if user == uniqueID:
			# skip own username
			continue
		if not playerinstances.has(user):
			# ID not found?
			print("Warning: unknown ID tried to set username")
			continue
		playerinstances[user].set_username(usernames[user])

remote func set_all_avatars(avatars: Dictionary):
	# avatars currently only 1
	pass

remote func add_new_user(userid: int, username: String, avatar: int):
	create_peer_instance(userid, username, avatar)

remote func set_client_emote(userid: int, emote: int):
	if playerinstances.has(userid):
		var target = playerinstances[userid]
		target.emote(emote)

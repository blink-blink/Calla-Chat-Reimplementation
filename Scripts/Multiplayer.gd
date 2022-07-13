extends Node

signal pos_updated

var playerinstances = {} # keeps track of all player instances in the map
var serverIP = "192.168.195.1"
var serverPort = 22552
var uniqueID: int # our rpc id
var mainplayerusername: String # our username
var mappath = "../Map1/YSort"
var curtimestamp = -1 # timestamp for position updates
const CLIENT_TICK_RATE =  1.0/45
const SERVER_TICK_RATE = 1.0/20
var tick = 0 
var active: bool = false # bool for if game is active

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
	get_tree().change_scene_to(Resources.scenes["map1"])
	# buffer idle frames to make sure map has loaded
	yield(get_tree(),"idle_frame")
	yield(get_tree(),"idle_frame")
	
	# debug ------------------------------------------------------------------------------
	# debug_conn_success() # IMPORTANT - REMOVE WHEN TESTING ACTUAL MULTIPLAYER CONNECTIVITY
	# debug ------------------------------------------------------------------------------

func create_main_instance(username = "user", avatar = 0, position = Vector2(20, 0)):
	var ysort = get_node(mappath)
	var camera = ysort.get_node("PlayerCamera")
	var instance = Resources.nodes["ControlledPlayer"].instance()
	ysort.add_child(instance)
	instance.global_position = position
	instance.name = str(uniqueID)
	instance.set_username(username)
	camera.set_player(instance)
	playerinstances[uniqueID] = instance
	return instance
	

func register_main_instance(instance):
	rpc("register_client", mainplayerusername, instance.avatar, instance.global_position.x, instance.global_position.y)

func create_peer_instance(ID, username = "user", avatar = 0, position = Vector2(0, 0)):
	# Grab YSort and add peer instance as child of YSort
	var ysort = get_node(mappath)
	var instance = Resources.nodes["PeerPlayer"].instance()
	ysort.add_child(instance)
	instance.global_position = position
	instance.name = str(ID)
	instance.set_username(username)
	playerinstances[ID] = instance
	return instance
	
func debug_conn_success():
	# debug function to mimic getting a successful connection	
	uniqueID = get_tree().get_network_unique_id()
	var main_instance = create_main_instance(mainplayerusername)
	register_main_instance(main_instance)
	var instance = create_peer_instance(1)
	instance.update_player(Vector2(25,0))

func connection_success():
	# on successful connection, store ID, create and register main instance
	uniqueID = get_tree().get_network_unique_id()
	var main_instance = create_main_instance(mainplayerusername)
	register_main_instance(main_instance)
	active = true

func connection_failure():
	print("Connection unsuccessful")
	
func initiate_disconnect():
	rpc("disconnect_me")
	active = false
	
func disconnected():
	print("Disconnected")
	active = false

func update_player_position(position: Vector2):
	if not active:
		return
	rpc_unreliable("update_client_position", position.x, position.y, OS.get_system_time_msecs())

func send_emote(emoteint: int):
	if not active:
		return
	rpc("set_client_emote", uniqueID, emoteint)
	
remote func disconnect_me(id):
	if playerinstances.has(id):
		# delete instance from dictionary and scene
		playerinstances[id].queue_free()
		playerinstances.erase(id)

remote func set_all_user_positions(positions: Dictionary, timestamp: int):
	if not active:
		return
	if timestamp < curtimestamp:
		# reject out of order packets
		return
	for user in positions.keys():
		if user == uniqueID:
			# skip own position
			continue
		if playerinstances.has(user):
			playerinstances[user].update_player(Vector2(positions[user]["x"],positions[user]["y"]))
		else:
			var instance = create_peer_instance(user)
			instance.update_player(Vector2(positions[user]["x"],positions[user]["y"]))
	curtimestamp = timestamp
	emit_signal("pos_updated")

remote func set_all_usernames(usernames: Dictionary):
	if not active:
		return
	yield(self, "pos_updated") # wait until position update is done
	for user in usernames.keys():
		if user == uniqueID:
			# skip own username
			continue
		if playerinstances.has(user):
			playerinstances[user].set_username(usernames[user])
		else:
			# ID not found
			print("Warning: unknown ID tried to set username")
			print(user)
			continue

remote func set_all_avatars(avatars: Dictionary):
	if not active:
		return
	# avatars currently only 1
	pass

remote func add_new_user(userid: int, username: String, avatar: int):
	if not active:
		return
	create_peer_instance(userid, username, avatar)

remote func set_client_emote(userid: int, emote: int):
	if not active:
		return
	if playerinstances.has(userid):
		var target = playerinstances[userid]
		target.emote(emote)

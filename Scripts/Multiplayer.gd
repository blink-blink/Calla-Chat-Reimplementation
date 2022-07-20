extends Node

signal pos_setup

var playerinstances = {} # keeps track of all player instances in the map
var serverIP = "192.168.195.1"
var serverPort = 22552
var uniqueID # our rpc id
var mainplayerusername: String # our username
var mainplayeravatar: int # our chosen avatar
var mappath = "../Map1/YSort"
var curtimestamp = -1 # timestamp for position updates
var active: bool = false # bool for if game is active
var setupcomplete: bool = false
var domain = "192.168.195.1:5060"
var usernumber : int

func _ready():
	get_tree().connect("connected_to_server", self, "connection_success")
	get_tree().connect("connection_failed", self, "connection_failure")
	get_tree().connect("server_disconnected", self, "disconnected")
	
func create_caller(callnumber:String, password:String):
	usernumber = int(callnumber)
	var callPort = usernumber + 29000
	var debug_output = 1 # 1 for debug output to stdout, 0 for none
	# debug
	# callnumber = "804"
	# callPort = 29804
	# end of debug
	Pjsip.add_account(callnumber, password, domain, callPort, debug_output)
	
func start_call():
	var endpoint = usernumber+498
	# debug endpoint
	# endpoint = 803
	# end of debug endpoint
	var call_uri = "sip:%s@192.168.195.1:5060" % str(endpoint)
	Pjsip.make_call(call_uri,GlobalAudioStreamPlayer.stream)

func start_client(username, avatar, callnumber, password):
	# connect to server
	var peer = NetworkedMultiplayerENet.new()
	peer.create_client(serverIP, serverPort)
	get_tree().network_peer = peer
	mainplayerusername = username
	mainplayeravatar = avatar
	create_caller(callnumber, password)
	get_tree().change_scene_to(Resources.scenes["map1"])
	# buffer idle frames to make sure map has loaded
	yield(get_tree(),"idle_frame")
	yield(get_tree(),"idle_frame")
	
	# debug ------------------------------------------------------------------------------
	# debug_conn_success() # IMPORTANT - REMOVE WHEN TESTING ACTUAL MULTIPLAYER CONNECTIVITY
	# debug ------------------------------------------------------------------------------

func create_main_instance(username = "user", avatar = 1, position = Vector2(20, 0)):
	var ysort = get_node(mappath)
	var camera = ysort.get_node("PlayerCamera")
	var instance = Resources.nodes["ControlledPlayer"].instance()
	ysort.add_child(instance)
	instance.global_position = position
	instance.name = str(uniqueID)
	instance.set_username(username)
	instance.set_avatar(avatar)
	instance.set_network_master(1)
	camera.set_player(instance)
	playerinstances[uniqueID] = instance
	return instance
	

func register_main_instance(instance):
	rpc_id(1,"register_client", mainplayerusername, mainplayeravatar, instance.global_position.x, instance.global_position.y)

func create_peer_instance(ID, username = "user", avatar = 1, position = Vector2(0, 0)):
	# Grab YSort and add peer instance as child of YSort
	var ysort = get_node(mappath)
	var instance = Resources.nodes["PeerPlayer"].instance()
	ysort.add_child(instance)
	instance.global_position = position
	instance.name = username
	instance.set_username(username)
	instance.set_avatar(avatar)
	instance.set_network_master(1)
	playerinstances[ID] = instance
	return instance

func connection_success():
	# on successful connection, store ID, create and register main instance and try to make call
	print("connection successful")
	uniqueID = get_tree().get_network_unique_id()
	var main_instance = create_main_instance(mainplayerusername, mainplayeravatar)
	register_main_instance(main_instance)
	start_call()
	active = true

func connection_failure():
	print("connection unsuccessful")
	
func initiate_disconnect():
	rpc_id(1,"disconnect_me")
	get_tree().network_peer.close_connection()
	reset_state()
	
func reset_state():
	active = false
	setupcomplete = false
	playerinstances.clear()	
	mainplayerusername = ""
	curtimestamp = -1
	uniqueID = null
	
func disconnected():
	print("disconnected")
	reset_state()
	get_tree().change_scene_to(Resources.scenes["titlescreen"])

func update_player_position(position: Vector2):
	if not active:
		return
	rpc_unreliable_id(1,"update_client_position", position.x, position.y, OS.get_system_time_msecs())

func send_emote(emoteint: int):
	if not active:
		return
	rpc_id(1,"set_client_emote", emoteint)
	
remote func disconnect_me(id):
	if playerinstances.has(id):
		# delete instance from dictionary and scene
		playerinstances[id].queue_free()
		playerinstances.erase(id)

remote func set_user_data(userdata: Dictionary):
	if not active:
		return
	for clientID in userdata.keys():
		if clientID == uniqueID:
			# skip own position
			continue
		create_peer_instance(clientID, userdata[clientID]["username"], userdata[clientID]["avatar"], Vector2(userdata[clientID]["x"],userdata[clientID]["y"]))
	setupcomplete = true
	
remote func update_all_user_positions(positions: Dictionary, timestamp: int):
	if not active or not setupcomplete:
		return
	if timestamp < curtimestamp:
		# reject out of order packets
		return
	for userID in positions.keys():
		if userID == uniqueID:
			# skip own position
			continue
		if playerinstances.has(userID):
			playerinstances[userID].update_player(Vector2(positions[userID]["x"],positions[userID]["y"]))
		else:
			print("new user tried to update with no instance yet")
	curtimestamp = timestamp

remote func add_new_user(userid: int, username: String, avatar: int):
	if not active:
		return
	if not setupcomplete:
		yield(get_tree(),"idle_frame") # wait if setup not yet complete
	create_peer_instance(userid, username, avatar)

remote func set_client_emote(userid: int, emote: int):
	if not active:
		return
	if playerinstances.has(userid):
		var target = playerinstances[userid]
		target.emote(emote)

func debug_conn_success():
	# debug function to mimic getting a successful connection	
	uniqueID = get_tree().get_network_unique_id()
	var main_instance = create_main_instance(mainplayerusername, mainplayeravatar)
	register_main_instance(main_instance)
	active = true
	var instance = create_peer_instance(1)
	debug_move_test(instance)
	
func debug_move_test(instance):
	instance.update_player(Vector2(50,0))
	yield(get_tree().create_timer(0.2), "timeout")
	instance.update_player(Vector2(50,0))
	yield(get_tree().create_timer(0.2), "timeout")
	instance.update_player(Vector2(50,0))
	yield(get_tree().create_timer(0.2), "timeout")
	instance.update_player(Vector2(30,0))
	yield(get_tree().create_timer(0.2), "timeout")
	instance.update_player(Vector2(30,0))
	yield(get_tree().create_timer(0.2), "timeout")
	instance.update_player(Vector2(0,30))
	yield(get_tree().create_timer(0.2), "timeout")
	instance.update_player(Vector2(0,30))
	yield(get_tree().create_timer(0.2), "timeout")
	instance.update_player(Vector2(0,30))
	yield(get_tree().create_timer(0.2), "timeout")
	instance.update_player(Vector2(0,30))
	yield(get_tree().create_timer(0.2), "timeout")
	instance.update_player(Vector2(0,30))
	yield(get_tree().create_timer(0.2), "timeout")
	instance.update_player(Vector2(-10,0))
	yield(get_tree().create_timer(0.2), "timeout")
	instance.update_player(Vector2(-10,0))
	yield(get_tree().create_timer(0.2), "timeout")
	instance.update_player(Vector2(-10,0))
	yield(get_tree().create_timer(0.2), "timeout")
	instance.update_player(Vector2(-10,0))
	yield(get_tree().create_timer(0.2), "timeout")
	instance.update_player(Vector2(-10,0))
	yield(get_tree().create_timer(0.2), "timeout")
	instance.update_player(Vector2(-30,-30))
	yield(get_tree().create_timer(0.2), "timeout")
	instance.update_player(Vector2(-30,-30))
	yield(get_tree().create_timer(0.2), "timeout")
	instance.update_player(Vector2(-30,-30))
	yield(get_tree().create_timer(0.2), "timeout")
	instance.update_player(Vector2(-30,-30))
	yield(get_tree().create_timer(0.2), "timeout")
	instance.update_player(Vector2(-30,-30))
	yield(get_tree().create_timer(0.2), "timeout")

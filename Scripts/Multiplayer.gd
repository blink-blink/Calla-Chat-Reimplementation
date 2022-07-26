extends Node

signal pos_setup
signal registered

var playerinstances = {} # keeps track of all player instances in the map
var serverIP = "192.168.195.1"
var serverPort = 22552
var uniqueID # our rpc id
var mainplayerusername: String # our username
var mainplayeravatar: int = 1 # our chosen avatar
var mainplayerpassword
var mappath = "../Map1/YSort"
var curtimestamp = -1 # timestamp for position updates
var active: bool = false # bool for if we send data to server
var setupcomplete: bool = false # bool for if we are ready to accept further data from server (aside from initial setup)
var domain = "192.168.195.1:5060"
var usernumber

func _ready():
	get_tree().connect("connected_to_server", self, "connection_success")
	get_tree().connect("connection_failed", self, "connection_failure")
	get_tree().connect("server_disconnected", self, "disconnected")
	
func create_caller(callnumber:String, password:String):
	usernumber = int(callnumber)
	var callPort = usernumber + 29000
	var debug_output = 1 # 1 for debug output to stdout, 0 for none
	
	print(callPort)
	Pjsip.initialize_endpoint(callPort, debug_output)
	Pjsip.add_account(callnumber, password, domain)
	
func start_call():
	var endpoint = usernumber+498
	var call_uri = "sip:%s@192.168.195.1:5060" % str(endpoint)
	Pjsip.make_call(call_uri,GlobalAudioStreamPlayer.stream)

func start_client(username, avatar, callnumber, password):
	# connect to server
	var peer = NetworkedMultiplayerENet.new()
	peer.create_client(serverIP, serverPort)
	get_tree().network_peer = peer
	mainplayerusername = username
	mainplayeravatar = avatar
	mainplayerpassword = password
	create_caller(callnumber, password)
	get_tree().change_scene_to(Resources.scenes["map1"])
	# buffer idle frames to make sure map has loaded
	yield(get_tree(),"idle_frame")
	yield(get_tree(),"idle_frame")

func start_client_no_call(username, avatar):
	# connect to server but do not try to call again
	var peer = NetworkedMultiplayerENet.new()
	peer.create_client(serverIP, serverPort)
	get_tree().network_peer = peer
	mainplayerusername = username
	mainplayeravatar = avatar
	get_tree().change_scene_to(Resources.scenes["map1"])
	# buffer idle frames to make sure map has loaded
	yield(get_tree(),"idle_frame")
	yield(get_tree(),"idle_frame")

func create_main_instance(username = "user", avatar = 1, position = Vector2(20, 0)):
	# creates player controlled character
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
	# registers player controlled character to game server
	rpc_id(1,"register_client", mainplayerpassword, mainplayerusername, mainplayeravatar, instance.global_position.x, instance.global_position.y)

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
	if not active:
		pass
		#client makes the call
		#start_call()
	register_main_instance(main_instance)

func connection_failure():
	print("connection unsuccessful")
	
func initiate_disconnect():
	# initiates graceful disconnect
	rpc_id(1,"disconnect_me", mainplayerpassword)
	reset_state()
	
func reset_state():
	# resets variables to mimic clean slate of newly opening up app
	get_tree().network_peer.close_connection()
	Pjsip.hangup_all_calls()
	active = false
	setupcomplete = false
	playerinstances.clear()	
	mainplayerusername = ""
	mainplayeravatar = 1
	mainplayerpassword = null
	usernumber = null
	curtimestamp = -1
	uniqueID = null
	
func disconnected():
	print("disconnected, trying reconnect")
	var storeusername = mainplayerusername
	reset_state()
	get_tree().change_scene_to(Resources.scenes["titlescreen"])
	var alert = get_node("/root/TitleScreen")
	alert.on_disconnect()

func update_player_position(position: Vector2):
	if not active:
		return
	rpc_unreliable_id(1,"update_client_position", mainplayerpassword, position.x, position.y, OS.get_system_time_msecs())

func send_emote(emoteint: int):
	if not active:
		return
	rpc_id(1,"set_client_emote", mainplayerpassword, emoteint)
	
remote func disconnect_me(id):
	if playerinstances.has(id):
		# delete instance from dictionary and scene
		playerinstances[id].queue_free()
		playerinstances.erase(id)

remote func set_user_data(userdata: Dictionary):
	for clientID in userdata.keys():
		if clientID == uniqueID:
			# skip own position
			continue
		create_peer_instance(clientID, userdata[clientID]["username"], userdata[clientID]["avatar"], Vector2(userdata[clientID]["x"],userdata[clientID]["y"]))
	setupcomplete = true
	
remote func update_all_user_positions(positions: Dictionary, timestamp: int):
	if not setupcomplete:
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
	if not setupcomplete:
		yield(get_tree(),"idle_frame") # wait if setup not yet complete
	create_peer_instance(userid, username, avatar)

remote func set_client_emote(userid: int, emote: int):
	if not setupcomplete:
		return
	if playerinstances.has(userid):
		var target = playerinstances[userid]
		target.emote(emote)
		
remote func reg_status(success: bool):
	print(success)
	if success:
		active = true
		emit_signal("registered")
	else:
		active = false
		get_tree().network_peer.close_connection()
		reset_state()
		get_tree().change_scene_to(Resources.scenes["titlescreen"])
		yield(get_tree(),"idle_frame")
		yield(get_tree(),"idle_frame")
		var alert = get_node("/root/TitleScreen")
		alert.on_UnsucessfulReg()
		print("reg unsuccessful")

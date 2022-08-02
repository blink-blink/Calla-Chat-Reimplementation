extends Node

var serverIP = "192.168.192.1"
var serverPort = 22000
onready var roomserver: StreamPeerTCP = StreamPeerTCP.new()

func _ready():
	roomserver.big_endian = true

func _process(_delta):
	pass

func get_room_port(roomname:String) -> int:
	if roomserver.connect_to_host(serverIP, serverPort) != OK:
		print("Can't connect to room server: %s" % (serverIP + ":" + str(serverPort)))
		return -1
	else:
		roomserver.put_data(roomname.to_ascii())
		while(true):
			if roomserver.get_status() != roomserver.STATUS_CONNECTED:
				print("tcp stream not connected")
				return -1
			var recv_bytes = roomserver.get_available_bytes()
			if recv_bytes > 0:
				var port = roomserver.get_string()
				roomserver.disconnect_from_host()
				print(port)
				return int(port)
	return -1

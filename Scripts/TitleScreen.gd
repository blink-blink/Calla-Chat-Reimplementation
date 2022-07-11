extends Control

onready var usernamefield = get_node("UserName")

func _on_JoinRoom_pressed():
	var username
	if usernamefield.text == "":
		username = "user"
	else:
		username = usernamefield.text
	Multiplayer.start_client(username)
	

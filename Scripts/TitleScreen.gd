extends Control

onready var usernamefield = get_node("UserName")

# function for when join room button is pressed
func _on_JoinRoom_pressed():
	var username
	if usernamefield.text == "":
		username = "user"
	else:
		username = usernamefield.text
	Multiplayer.start_client(username)
	

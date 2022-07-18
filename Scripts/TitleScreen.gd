extends Control

onready var usernamefield = get_node("UserName")
onready var avatarfield = get_node("Avatar")

# function for when join room button is pressed
func _on_JoinRoom_pressed():
	var username
	var avatar = avatarfield.value
	if usernamefield.text == "":
		username = "user"
	else:
		username = usernamefield.text
	Multiplayer.start_client(username, avatar)
	

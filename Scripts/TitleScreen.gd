extends Control

onready var usernamefield = get_node("UserName")
onready var roomnamefield = get_node("RoomName")
onready var avatarfield = get_node("Avatar")
onready var filedialog = get_node("FileDialog")
onready var configalert = get_node("ConfigAlert")
onready var configlabel = get_node("ConfigAlert/Label")
var password
var ipaddr
# function for when join room button is pressed
func _on_JoinRoom_pressed():
	var username
	var roomname
	var avatar = avatarfield.value
	if usernamefield.text == "":
		username = "user"
	else:
		username = usernamefield.text
	if roomnamefield.text == "":
		configlabel.text = "Enter a room name!"
		configalert.popup_centered_clamped()
	else:
		roomname = roomnamefield.text
	if ipaddr and password:
		Multiplayer.start_client(username, avatar, ipaddr, password, roomname)
	else:
		configlabel.text = "No config file selected!"
		configalert.popup_centered_clamped()
	


func _on_ChooseConfig_pressed():
	filedialog.popup_centered_clamped()
	
func on_UnsucessfulReg():
	configlabel.text = "Unsuccessfull Registration!\n (Mabye someone already has that username)"
	configalert.popup_centered_clamped()

func popup(msg):
	configlabel.text = msg
	configalert.popup_centered_clamped()
	
func on_disconnect():
	configlabel.text = "Disconnected!"
	configalert.popup_centered_clamped()

func _on_FileDialog_file_selected(path:String):
	if path.get_extension() != "conf":
		configlabel.text = "Invalid config file selected!"
		configalert.popup_centered_clamped()
		return
	var file = File.new()
	file.open(path, File.READ)
	var content = file.get_as_text()
	var splitlines = content.split("\n")
	# Hardcoded config parsing
	password = splitlines[0].substr(10).strip_edges()
	ipaddr = splitlines[2].substr(10).strip_edges().trim_suffix("/24")
	print(ipaddr)

extends Control

onready var usernamefield = get_node("UserName")
onready var avatarfield = get_node("Avatar")
onready var filedialog = get_node("FileDialog")
onready var configalert = get_node("ConfigAlert")
onready var configlabel = get_node("ConfigAlert/Label")
var password
var usernumber
# function for when join room button is pressed
func _on_JoinRoom_pressed():
	var username
	var avatar = avatarfield.value
	if usernamefield.text == "":
		username = "user"
	else:
		username = usernamefield.text
	if usernumber and password:
		Multiplayer.start_client(username, avatar, usernumber, password)
	else:
		configlabel.text = "No config file selected!"
		configalert.popup_centered_clamped()
	


func _on_ChooseConfig_pressed():
	filedialog.popup_centered_clamped()
	


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
	var address = splitlines[2].substr(10).strip_edges()
	usernumber = str(int(address.trim_suffix("/24").split(".")[3])+198)

extends Panel

onready var player = get_node("../../../YSort/Player")

# Called when the node enters the scene tree for the first time.
func _ready():
	self.hide()

func _input(event):
	if event.is_action_pressed("emote"):
		if self.is_visible_in_tree():
			self.hide()
		else:
			self.show()

# each emote has a caller function together with preloaded texture
func _on_Clap_pressed():
	player.start_emote("clap")


func _on_Yes_pressed():
	player.start_emote("check")


func _on_No_pressed():
	player.start_emote("cross")


func _on_Ok_pressed():
	player.start_emote("heart")


func _on_ThumbsUp_pressed():
	player.start_emote("thumbsup")


func _on_Raise_pressed():
	player.start_emote("raise")


func _on_Heart_pressed():
	player.start_emote("heart")


func _on_Party_pressed():
	player.start_emote("party")

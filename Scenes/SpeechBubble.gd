extends Sprite


onready var emote_sprite = get_node("Emote")
var check = preload("res://Assets/UI/Emotes/check.png")
var clap = preload("res://Assets/UI/Emotes/clap.png")
var cross = preload("res://Assets/UI/Emotes/cross.png")


# Called when the node enters the scene tree for the first time.
func _ready():
	self.hide()
	
func startEmote():
	self.show()
	yield(get_tree().create_timer(5.0), "timeout")
	self.hide()

func _on_Clap_pressed():
	emote_sprite.set_texture(clap)
	startEmote()


func _on_Yes_pressed():
	emote_sprite.set_texture(check)
	startEmote()


func _on_No_pressed():
	emote_sprite.set_texture(cross)
	startEmote()

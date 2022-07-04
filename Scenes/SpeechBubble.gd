extends Sprite


onready var emote_sprite = get_node("Emote")
onready var timer = get_node("Timer")
var check = preload("res://Assets/UI/Emotes/check.png")
var clap = preload("res://Assets/UI/Emotes/clap.png")
var cross = preload("res://Assets/UI/Emotes/cross.png")
var heart = preload("res://Assets/UI/Emotes/heart.png")
var ok = preload("res://Assets/UI/Emotes/ok.png")
var party = preload("res://Assets/UI/Emotes/party.png")
var raise = preload("res://Assets/UI/Emotes/raise.png")
var thumbsup = preload("res://Assets/UI/Emotes/thumbsup.png")


func _ready():
	self.hide()

# shows emote by showing and hiding speech bubble with emote, uses a timer to time emote duration
func startEmote():
	self.show()
	timer.start(5)
	yield(timer, "timeout")
	self.hide()

# each emote has a caller function together with preloaded texture
func _on_Clap_pressed():
	emote_sprite.set_texture(clap)
	startEmote()


func _on_Yes_pressed():
	emote_sprite.set_texture(check)
	startEmote()


func _on_No_pressed():
	emote_sprite.set_texture(cross)
	startEmote()


func _on_Ok_pressed():
	emote_sprite.set_texture(ok)
	startEmote()


func _on_ThumbsUp_pressed():
	emote_sprite.set_texture(thumbsup)
	startEmote()


func _on_Raise_pressed():
	emote_sprite.set_texture(raise)
	startEmote()


func _on_Heart_pressed():
	emote_sprite.set_texture(heart)
	startEmote()


func _on_Party_pressed():
	emote_sprite.set_texture(party)
	startEmote()

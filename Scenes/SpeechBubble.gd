extends Sprite


onready var emote_sprite = get_node("Emote")
onready var timer = get_node("Timer")
onready var check = Resources.emotes["check"]
onready var clap = Resources.emotes["clap"]
onready var cross = Resources.emotes["cross"]
onready var heart = Resources.emotes["heart"]
onready var ok = Resources.emotes["ok"]
onready var party = Resources.emotes["party"]
onready var raise = Resources.emotes["raise"]
onready var thumbsup = Resources.emotes["thumbsup"]


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

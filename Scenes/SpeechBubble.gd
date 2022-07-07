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
var emotearray = [] # index of emote is its integer representation


func _ready():
	emotearray.append(null)
	emotearray.append(clap)
	emotearray.append(check)
	emotearray.append(cross)
	emotearray.append(ok)
	emotearray.append(thumbsup)
	emotearray.append(raise)
	emotearray.append(heart)
	emotearray.append(party)
	self.hide()

# shows emote by showing and hiding speech bubble with emote, uses a timer to time emote duration
func startEmote(emotenumber):
	emote_sprite.set_texture(emotearray[emotenumber])
	self.show()
	timer.start(5)
	yield(timer, "timeout")
	self.hide()

# each emote has a caller function together with preloaded texture
func _on_Clap_pressed():
	startEmote(1)


func _on_Yes_pressed():
	startEmote(2)


func _on_No_pressed():
	startEmote(3)


func _on_Ok_pressed():
	startEmote(4)


func _on_ThumbsUp_pressed():
	startEmote(5)


func _on_Raise_pressed():
	startEmote(6)


func _on_Heart_pressed():
	startEmote(7)


func _on_Party_pressed():
	startEmote(8)

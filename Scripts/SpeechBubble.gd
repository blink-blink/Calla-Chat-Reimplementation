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

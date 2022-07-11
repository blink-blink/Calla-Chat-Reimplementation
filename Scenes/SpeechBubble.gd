extends Sprite


onready var emote_sprite = get_node("Emote")
onready var timer = get_node("Timer")


func _ready():
	self.hide()

# shows emote by showing and hiding speech bubble with emote, uses a timer to time emote duration
func show_emote(emote_type: String):
	
	emote_sprite.set_texture(GameData.emotes[emote_type])
	
	self.show()
	timer.start(5)
	yield(timer, "timeout")
	self.hide()

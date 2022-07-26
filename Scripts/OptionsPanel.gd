extends Panel


onready var volumeslide = get_node("VBoxContainer/VolumeSlider")

# Called when the node enters the scene tree for the first time.
func _ready():
	volumeslide.value = GlobalAudioStreamPlayer.volume_db


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Button_pressed():
	self.hide()


func _on_HSlider_value_changed(value):
	#volumeslider signal
	GlobalAudioStreamPlayer.volume_db = value
	var valuelabel = volumeslide.get_child(1)
	valuelabel.text = str(value)

extends Panel


onready var volumeslide = get_node("VBoxContainer/VolumeSlider")

# Called when the node enters the scene tree for the first time.
func _ready():
	volumeslide.value = db2linear(GlobalAudioStreamPlayer.volume_db)
	var valuelabel = volumeslide.get_child(1)
	valuelabel.text = str(volumeslide.value)


func _on_Button_pressed():
	self.hide()


func _on_HSlider_value_changed(value):
	# volumeslider, changes volume of call and converts linear values to db and vice versa for user friendliness
	GlobalAudioStreamPlayer.volume_db = linear2db(value)
	var valuelabel = volumeslide.get_child(1)
	valuelabel.text = str(value)

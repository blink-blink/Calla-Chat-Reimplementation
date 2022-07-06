extends Node2D
var meeting_started: bool = false
signal start_meeting
signal stop_meeting
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Button_pressed():
	if not meeting_started:
		$meeting.text = "Stop Meeting"
		meeting_started = true
		emit_signal("start_meeting",$hostname.text,int($host_avatar.text))
	else:
		$meeting.text = "Start Meeting"
		meeting_started = false
		emit_signal("stop_meeting")

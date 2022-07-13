extends Control

func _ready():
	set_visible(false)	

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		visible = !visible

func _on_Quit_pressed():
	Multiplayer.initiate_disconnect()
	get_tree().change_scene("res://Scenes/TitleScreen.tscn")

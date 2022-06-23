extends Control

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		visible = !visible


func _on_Quit_pressed():
	get_tree().change_scene("res://Scenes/TitleScreen.tscn")

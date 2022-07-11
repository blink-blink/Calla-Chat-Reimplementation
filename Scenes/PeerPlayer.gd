extends KinematicBody2D

var username
var avatar

func set_username(name):
	var label = get_node("Username")
	label.text = name

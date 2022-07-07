# Singleton for resources to be used in the game, they're all loaded here
extends Node

var emotes = {}

func _ready():
	emotes["check"] = preload("res://Assets/UI/Emotes/check.png")
	emotes["clap"] = preload("res://Assets/UI/Emotes/clap.png")
	emotes["cross"] = preload("res://Assets/UI/Emotes/cross.png")
	emotes["heart"] = preload("res://Assets/UI/Emotes/heart.png")
	emotes["ok"] = preload("res://Assets/UI/Emotes/ok.png")
	emotes["party"] = preload("res://Assets/UI/Emotes/party.png")
	emotes["raise"] = preload("res://Assets/UI/Emotes/raise.png")
	emotes["thumbsup"] = preload("res://Assets/UI/Emotes/thumbsup.png")

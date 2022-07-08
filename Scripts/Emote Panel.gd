extends Panel

func _ready():
	self.hide()

func _input(event):
	if event.is_action_pressed("emote"):
		if self.is_visible_in_tree():
			self.hide()
		else:
			self.show()

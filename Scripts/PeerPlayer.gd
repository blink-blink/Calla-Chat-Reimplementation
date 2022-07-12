extends Character

func control(delta):
	# traverse path if any
	traverse_path(delta)
	
	# move based on vel
	vel = vel.normalized()
	vel = move_and_slide(vel*move_speed)
	
	return false

func update_player(position: Vector2):
	# meant to be called only on peerplayers
	if (position - self.global_position).length() >= move_speed*SERVER_TICK_RATE*3:
		# teleport if distance moved is too great
		self.global_position = position
	else:
		# else just pathfind there
		generate_path(self.global_position, position)

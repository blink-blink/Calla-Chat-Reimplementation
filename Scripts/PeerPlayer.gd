# peer player is a player instance meant to represent other players aside from ourselves in the map
extends Character

func control(delta):
	# traverse path if any
	traverse_path(delta)
	
	# move based on vel
	vel = vel.normalized()
	vel = move_and_slide(vel*move_speed)
	vel = Vector2.ZERO
	
	return false

func update_player(position: Vector2):
	# meant to be called only on peerplayers
	var distance = (position - self.global_position).length()
	if distance >= move_speed*SERVER_TICK_RATE*3:
		# teleport if distance moved is too great
		self.global_position = position
	elif distance <= move_speed*SERVER_TICK_RATE:
		# interpolate if close to destination
		self.global_position = self.global_position.linear_interpolate(position, SERVER_TICK_RATE)
	else:
		# else just pathfind there
		generate_path(self.global_position, position)

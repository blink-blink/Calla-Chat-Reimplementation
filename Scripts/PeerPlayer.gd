# peer player is a player instance meant to represent other players aside from ourselves in the map
extends Character

var interpolating : bool
var interpolto : Vector2

func control(delta):
	# traverse path if any
	traverse_path(delta)
	
	# move based on vel
	vel = vel.normalized()
	vel = move_and_slide(vel*move_speed)
	vel = Vector2.ZERO
	
	return false

func animate():
	# custom animations for peerplayer to account for linear_interpolation
	if vel.length_squared() < 0.01 and not interpolating:
		# idle frame
		sprite.set_frame(0)
		sprite.stop()
	else:
		# change animation direction based on vel angle
		if not interpolating:
			curangle = vel.angle()
		else:
			curangle = self.global_position.angle_to_point(interpolto)
		if curangle > -PI/4 and curangle < PI/4:
			sprite.play("run right")
		elif (curangle > PI/4 or is_equal_approx(curangle,PI/4)) and (curangle < 3*PI/4 or is_equal_approx(curangle,3*PI/4)):
			sprite.play("run down")
		elif (curangle > -3*PI/4 or is_equal_approx(curangle,-3*PI/4)) and (curangle < -PI/4 or is_equal_approx(curangle,-PI/4)):
			sprite.play("run up")
		else:
			sprite.play("run left")
		interpolating = false

func update_player(position: Vector2):
	# meant to be called only on peerplayers
	var distance = (position - self.global_position).length()
	if distance >= move_speed*SERVER_TICK_RATE*3:
		# teleport if distance moved is too great
		self.global_position = position
	elif distance <= move_speed*SERVER_TICK_RATE:
		# interpolate if close to destination
		self.global_position = self.global_position.linear_interpolate(position, SERVER_TICK_RATE)
		interpolating = true
		interpolto = position
	else:
		# else just pathfind there
		generate_path(self.global_position, position)

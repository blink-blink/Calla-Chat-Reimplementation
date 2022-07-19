# peer player is a player instance meant to represent other players aside from ourselves in the map
extends Character

var interpolating : bool
var interpolto : Vector2
var tween

func control(delta):
	# traverse path if any
	if tween:
		if tween.is_active():
			interpolating = true
		else:
			interpolating = false
	
	return false

func animate():
	# custom animations for peerplayer to account for linear_interpolation
	if interpolating and (interpolto-self.global_position).length_squared() != 0:
		# change animation direction based on vel angle
		curangle = (interpolto-self.global_position).angle()
		if curangle > -PI/4 and curangle < PI/4:
			sprite.play("run right")
		elif (curangle > PI/4 or is_equal_approx(curangle,PI/4)) and (curangle < 3*PI/4 or is_equal_approx(curangle,3*PI/4)):
			sprite.play("run down")
		elif (curangle > -3*PI/4 or is_equal_approx(curangle,-3*PI/4)) and (curangle < -PI/4 or is_equal_approx(curangle,-PI/4)):
			sprite.play("run up")
		else:
			sprite.play("run left")
	else:
		# idle frame
		sprite.set_frame(0)
		sprite.stop()


func update_player(position: Vector2):
	# meant to be called only on peerplayers
	var distance = (position - self.global_position).length()
	if distance >= move_speed*SERVER_TICK_RATE*3:
		# teleport if distance moved is too great
		self.global_position = position
	else:
		# interpolate if close to destination
		if !tween:
			print("tween instantiated")
			tween = Tween.new()
			self.add_child(tween)
		tween.interpolate_property(self, "position", self.global_position, position, SERVER_TICK_RATE)
		tween.start()
		interpolto = position

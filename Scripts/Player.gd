extends KinematicBody2D

var vel: Vector2
var dir: Vector2

var move_up = false
var move_down = false
var move_left = false
var move_right = false

var move_speed = 4000

func get_input():
	vel = Vector2()
	if Input.is_action_pressed("up"):
		vel.y -= 1
	if Input.is_action_pressed("down"):
		vel.y += 1
	if Input.is_action_pressed("left"):
		vel.x -= 1
	if Input.is_action_pressed("right"):
		vel.x += 1

func _physics_process(delta):
	get_input()
	vel = vel.normalized()
	vel = move_and_slide(vel*move_speed*delta)

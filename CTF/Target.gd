extends KinematicBody

var velocity : Vector3
var speed = 20
var move_left = false
var turn_around_dist = 40.0

func _physics_process(delta):
	var pos = global_transform.origin
	if move_left and pos.x < -turn_around_dist:
		move_left = false
		speed = -speed
	if !move_left and pos.x > turn_around_dist:
		move_left = true
		speed = -speed
	velocity = global_transform.basis.x * speed
	move_and_collide(velocity*delta)

func get_velocity():
	return velocity

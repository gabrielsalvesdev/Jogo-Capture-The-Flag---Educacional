extends Spatial

var nav : Navigation
var body_to_move: KinematicBody

export var move_speed = 10.0
var move_vec : Vector3

func setup(_body_to_move: KinematicBody, _nav: Navigation):
	body_to_move = _body_to_move
	nav = _nav

var goal_pos : Vector3
func _physics_process(delta):
	if !is_instance_valid(body_to_move) or !is_instance_valid(nav):
		return
	var our_pos = body_to_move.global_transform.origin
	var path = nav.get_simple_path(our_pos, goal_pos)
	if path.size() > 1:
		move_vec = path[1] - our_pos
		move_vec.y = 0.0
		move_vec = move_vec.normalized()
		body_to_move.move_and_slide(move_vec * move_speed, Vector3.UP)

func move_to_position(pos: Vector3):
	goal_pos = pos
	var our_pos = body_to_move.global_transform.origin
	pos.y = our_pos.y
	var dist = our_pos.distance_squared_to(pos)
	return dist < 0.1 * 0.1

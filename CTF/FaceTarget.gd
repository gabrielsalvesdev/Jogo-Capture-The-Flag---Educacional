extends Spatial

var obj_to_turn : Spatial

func setup(_obj_to_turn):
	obj_to_turn = _obj_to_turn

var turn_speed = 100.0
func face_point(point: Vector3, delta: float):
	if obj_to_turn == null:
		return
	var l_point = obj_to_turn.to_local(point)
	l_point.y = 0.0
	
	var turn_dir = sign(Vector3.RIGHT.dot(l_point))
	var turn_amnt = deg2rad(turn_speed * delta)
	var angle = Vector3.FORWARD.angle_to(l_point)
	
	if angle < turn_amnt:
		obj_to_turn.rotate_object_local(Vector3.UP, -angle * turn_dir)
	else:
		obj_to_turn.rotate_object_local(Vector3.UP, -turn_amnt * turn_dir)

func is_facing_target(target_point: Vector3):
	if obj_to_turn == null:
		return false
	var l_target_pos = to_local(target_point)
	return l_target_pos.z < 0 and abs(l_target_pos.x) < 1.0

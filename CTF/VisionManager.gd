extends Spatial

export var vision_cone_arc = 60.0
func in_vision_cone(point: Vector3):
	var fwd = -global_transform.basis.z
	var our_pos = global_transform.origin
	var dir_to_point = point - our_pos
	return dir_to_point.angle_to(fwd) <= deg2rad(vision_cone_arc/2.0)

func has_los(point: Vector3):
	var space_state = get_world().direct_space_state
	var result = space_state.intersect_ray(global_transform.origin, point, [], 1)
	return result.size() == 0

extends Spatial


onready var fire_point = $FaceTargetY/FaceTargetX/FirePoint
onready var face_target_y = $FaceTargetY
onready var face_target_x = $FaceTargetY/FaceTargetX

var bullet_obj = preload("res://Bullet.tscn")
export var bullet_speed = 40.0


var target : Spatial
func _ready():
	target = get_tree().get_nodes_in_group("targets")[0]

func _process(delta):
	var aim_at_point = get_aim_at_point()
	if aim_at_point != Vector3.INF:
		face_target_y.face_point(aim_at_point, delta)
		face_target_x.face_point(aim_at_point, delta)

func fire():
	var bullet_inst = bullet_obj.instance()
	bullet_inst.move_speed = bullet_speed
	bullet_inst.global_transform = fire_point.global_transform
	get_tree().get_root().add_child(bullet_inst)

func get_aim_at_point():
	if !target.has_method("get_velocity"):
		return target.global_transform.origin
	
	var Pti = target.global_transform.origin
	var Pbi = fire_point.global_transform.origin
	var D = Pti.distance_to(Pbi)
	var Vt = target.get_velocity()
	var St = Vt.length()
	var Sb = bullet_speed
	var cos_theta = Pti.direction_to(Pbi).dot(Vt.normalized())
	var q_root = sqrt(2*D*St*cos_theta + 4*(Sb*Sb - St*St)*D*D )
	var q_sub = (2*(Sb*Sb - St*St))
	var q_left = -2*D*St*cos_theta
	var t1 = (q_left + q_root) / q_sub
	var t2 = (q_left - q_root) / q_sub
	
	var t = min(t1, t2)
	if t < 0:
		t = max(t1, t2)
	if t < 0:
		return Vector3.INF # can't hit, target too fast
	
	return Vt * t + Pti

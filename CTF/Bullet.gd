extends KinematicBody

var move_speed = 0.0
var exploded = false
func _physics_process(delta):
	var move_dir = -global_transform.basis.z
	var coll = move_and_collide(move_dir * move_speed * delta)
	if coll:
		explode()

func explode():
	if exploded:
		return
	exploded = true
	collision_layer = 0
	collision_mask = 0
	set_physics_process(false)
	$ExplosionParticles.restart()
	$MeshInstance.hide()
	$DeleteTimer.start()
	

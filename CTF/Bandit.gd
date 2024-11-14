extends Character

onready var character_mover = $NPCCharacterMover
onready var face_target = $FaceTargetY
onready var vision_manager = $VisionManager
onready var character_detector = $CharacterDetector
onready var anim_player = $Graphics/AnimationPlayer

enum STATES {IDLE, PATROL, ATTACK, DEAD}
var cur_state = STATES.IDLE

var cur_target : Character

var start_pos : Vector3
var start_facing_dir : Vector3

var patrol_points = []
var patrol_ind = 0

export var attack_range = 3.0
export var attack_rate = 1.0
var last_attack_time = 0.0

export var time_till_return_to_idle = 5.0
var last_time_target_was_visible = 0.0

var health = 3

func _ready():
	var nav = get_tree().get_nodes_in_group("navigation")[0]
	character_mover.setup(self, nav)
	face_target.setup(self)
	start_pos = global_transform.origin
	start_facing_dir = -global_transform.basis.z
	
	if has_node("PatrolNodes") and get_node("PatrolNodes").get_child_count() > 0:
		set_patrol_state()
		for patrol_node in get_node("PatrolNodes").get_children():
			patrol_points.append(patrol_node.global_transform.origin)
	else:
		set_idle_state()

func _process(delta):
	match cur_state:
		STATES.IDLE:
			process_idle_state(delta)
		STATES.PATROL:
			process_patrol_state(delta)
		STATES.ATTACK:
			process_attack_state(delta)
		STATES.DEAD:
			process_dead_state(delta)

func set_idle_state():
	print('idling')
	cur_state = STATES.IDLE

func set_patrol_state():
	print('patrolling')
	cur_state = STATES.PATROL

func set_attack_state():
	print('spotted player')
	cur_state = STATES.ATTACK

func set_dead_state():
	print('died')
	cur_state = STATES.DEAD
	anim_player.play("death")

func process_idle_state(delta: float):
	if can_see_any_enemies():
		set_attack_state()
		return
	
	if character_mover.move_to_position(start_pos):
		face_target.face_point(start_pos + start_facing_dir, delta)
	else:
		face_dir_of_travel(delta)


func process_patrol_state(delta: float):
	if can_see_any_enemies():
		set_attack_state()
		return
	
	var our_pos = global_transform.origin
	var next_patrol_pos = patrol_points[patrol_ind]
	
	if face_target.is_facing_target(next_patrol_pos) or !vision_manager.has_los(next_patrol_pos):
		character_mover.move_to_position(next_patrol_pos)
		face_dir_of_travel(delta)
	else:
		character_mover.move_to_position(our_pos)
		face_target.face_point(next_patrol_pos, delta)
	
	next_patrol_pos.y = our_pos.y
	if our_pos.distance_squared_to(next_patrol_pos) < 0.1*0.1:
		patrol_ind += 1
		patrol_ind %= patrol_points.size()

func process_attack_state(delta: float):
	if !is_instance_valid(cur_target) or cur_target.is_dead():
		update_cur_target()
	
	if cur_target == null:
		return_to_start_state()
		return
	
	var our_pos = global_transform.origin
	var target_pos = cur_target.global_transform.origin
	
	var cur_time = OS.get_ticks_msec() / 1000.0
	if vision_manager.has_los(target_pos):
		last_time_target_was_visible = cur_time
	elif last_time_target_was_visible + time_till_return_to_idle < cur_time:
		return_to_start_state()
		return
	
	if our_pos.distance_squared_to(target_pos) < attack_range*attack_range:
		character_mover.move_to_position(our_pos)
		face_target.face_point(target_pos, delta)
		if face_target.is_facing_target(target_pos):
			attack()
	else:
		character_mover.move_to_position(target_pos)
		face_dir_of_travel(delta)

func process_dead_state(delta: float):
	pass

func attack():
	if cur_target == null:
		return
	var cur_time = OS.get_ticks_msec() / 1000.0
	if last_attack_time + attack_rate < cur_time:
		cur_target.hurt()
		last_attack_time = cur_time

func return_to_start_state():
	print('returning to start state')
	if patrol_points.size() > 0:
		set_patrol_state()
	else:
		set_idle_state()

func face_dir_of_travel(delta: float):
	face_target.face_point(global_transform.origin + character_mover.move_vec, delta)

func can_see_any_enemies():
	return get_visible_enemies().size() > 0

func update_cur_target():
	cur_target = null
	var v_enemies = get_visible_enemies()
	if v_enemies.size() == 0:
		return
	
	var our_pos = global_transform.origin
	cur_target = v_enemies[0]
	var dist = -1
	for enemy in v_enemies:
		if !is_instance_valid(enemy) or enemy.is_dead():
			continue
		var pos : Vector3 = enemy.global_transform.origin
		var d = pos.distance_squared_to(our_pos)
		if dist < 0 or dist > d:
			dist = d
			cur_target = enemy

func get_visible_enemies(use_vision_cone = true):
	var visible_enemies = []
	for enemy in character_detector.get_nearby_enemies():
		if is_instance_valid(enemy):
			var enemy_pos = enemy.global_transform.origin
			if (!use_vision_cone or vision_manager.in_vision_cone(enemy_pos)) and vision_manager.has_los(enemy_pos):
				visible_enemies.append(enemy)
	return visible_enemies

func hurt():
	if is_dead():
		return
	
	if cur_state != STATES.ATTACK:
		cur_target = get_visible_enemies(false)[0]
		set_attack_state()
	
	health -= 1
	if health <= 0:
		set_dead_state()

func is_dead():
	return cur_state == STATES.DEAD




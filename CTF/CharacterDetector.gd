extends Area


var nearby_allies = []
var nearby_enemies = []
var team = 0

func _ready():
	if get_parent() is Character:
		team = get_parent().team

func _physics_process(delta):
	update_nearby_characters()

func update_nearby_characters():
	nearby_allies = []
	nearby_enemies = []
	for body in get_overlapping_bodies():
		if body is Character:
			if body.team == team:
				nearby_allies.append(body)
			else:
				nearby_enemies.append(body)

func get_nearby_allies():
	return nearby_allies

func get_nearby_enemies():
	return nearby_enemies

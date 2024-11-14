extends Spatial

var collected = false
var flag_area

func _ready():
	add_to_group("flags")
	flag_area = Area.new()
	var collision_shape = CollisionShape.new()
	collision_shape.shape = BoxShape.new()
	collision_shape.shape.extents = Vector3(1, 1, 1) # Ajuste o tamanho da forma de colisão conforme necessário
	flag_area.add_child(collision_shape)
	add_child(flag_area)
	flag_area.connect("body_entered", self, "_on_flag_area_body_entered")

func _on_flag_area_body_entered(body):
	if body.is_in_group("player") and not collected:
		collect()

func collect():
	collected = true
	print("Flag collected!")  # Feedback no console
	# Notifica o jogador sobre a coleta
	var player = get_tree().get_nodes_in_group("player")[0]
	if player:
		player.collect_flag(self)
	visible = false
	flag_area.set_deferred("monitoring", false)
	flag_area.set_deferred("monitorable", false)

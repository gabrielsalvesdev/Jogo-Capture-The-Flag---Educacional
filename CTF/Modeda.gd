extends Spatial

signal collected

var collected = false
var coin_area

func _ready():
	coin_area = Area.new()
	var collision_shape = CollisionShape.new()
	collision_shape.shape = BoxShape.new()
	collision_shape.shape.extents = Vector3(1, 1, 1) # Ajuste conforme necessário
	coin_area.add_child(collision_shape)
	add_child(coin_area)
	coin_area.connect("body_entered", self, "_on_coin_area_body_entered")

func _on_coin_area_body_entered(body):
	if body is KinematicBody and not collected:
		collect()

func collect():
	collected = true
	get_tree().call_group("player", "_on_coin_collected", self)
	visible = false
	coin_area.set_deferred("monitoring", false)
	coin_area.set_deferred("monitorable", false)

func reset():
	collected = false
	visible = true
	coin_area.set_deferred("monitoring", true)
	coin_area.set_deferred("monitorable", true)

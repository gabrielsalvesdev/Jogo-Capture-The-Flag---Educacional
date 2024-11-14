extends Spatial

var player_in_area = false
var flag_collected = false
var proximo_area
var player

func _ready():
	proximo_area = Area.new()
	var collision_shape = CollisionShape.new()
	collision_shape.shape = BoxShape.new()
	collision_shape.shape.extents = Vector3(1, 1, 1)
	proximo_area.add_child(collision_shape)
	add_child(proximo_area)

	proximo_area.connect("body_entered", self, "_on_proximo_area_body_entered")
	proximo_area.connect("body_exited", self, "_on_proximo_area_body_exited")

	# Conectar ao sinal do jogador
	player = get_parent().get_node("Player")  # Ajuste o caminho conforme necessário
	player.connect("flag_collected", self, "_on_flag_collected")

	print("Proximo _ready() chamado")

func _on_flag_collected():
	print("Bandeira coletada detectada pelo Proximo!")
	flag_collected = true
	check_level_completion()

func _on_proximo_area_body_entered(body):
	print("Um corpo entrou na área do Proximo")
	if body.is_in_group("player"):
		player_in_area = true
		print("O jogador entrou na área do Proximo")
		check_level_completion()

func _on_proximo_area_body_exited(body):
	print("Um corpo saiu da área do Proximo")
	if body.is_in_group("player"):
		player_in_area = false
		print("O jogador saiu da área do Proximo")

func check_level_completion():
	if player_in_area and flag_collected:
		next_level()  # Avança para o próximo nível, se o jogador estiver na área e a bandeira tiver sido coletada
	else:
		print("O jogador precisa estar na área do Proximo e coletar a bandeira para avançar para o próximo nível.")

func next_level():
	print("Função next_level() chamada")
	get_tree().change_scene("res://Nivel3.tscn")

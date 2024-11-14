extends Character

signal flag_collected

var flag_collected = false  # Variável para rastrear se a bandeira foi coletada
var move_speed = 30.0
var max_health = 4  # Máximo de vezes que o jogador pode ser atingido antes de morrer
var current_health = max_health  # Vida atual do jogador

func _ready():
	add_to_group("player")  # Adiciona o jogador ao grupo "player"
	
	# Cria e configura a área de detecção da bandeira
	var flag_area = Area.new()
	flag_area.name = "FlagArea"
	var collision_shape = CollisionShape.new()
	collision_shape.shape = SphereShape.new()
	collision_shape.shape.radius = 1.0  # Ajuste o raio conforme necessário
	flag_area.add_child(collision_shape)
	add_child(flag_area)
	
	# Conecta o sinal 'body_entered' da área de detecção da bandeira
	flag_area.connect("body_entered", self, "_on_FlagArea_body_entered")

func _physics_process(delta):
	var move_vec = Vector3.ZERO
	move_vec.z = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	move_vec.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	move_vec = move_vec.normalized()
	move_and_slide(move_speed * move_vec, Vector3.UP)

func _process(delta):
	if Input.is_action_just_pressed("attack"):
		for body in $AttackArea.get_overlapping_bodies():
			if body is Character and body != self:
				body.hurt()

func _on_FlagArea_body_entered(body):
	if body.is_in_group("flags") and not flag_collected:
		collect_flag(body)

func collect_flag(flag):
	flag_collected = true  # Define a variável como verdadeira quando a bandeira for coletada
	emit_signal("flag_collected")
	print("Bandeira Capturada!")

func deliver_flag():
	if flag_collected:
		flag_collected = false  # Reseta a bandeira, se necessário
		print("AHHAHA")
		# Implemente aqui a lógica para entregar a bandeira e avançar de nível

func is_dead():
	return current_health <= 0

func hurt():
	current_health -= 1  # Reduz a vida do jogador em 1 quando for atingido
	print("Cuidado meu! Vida atual: ", current_health)
	
	if is_dead():
		die()  # Chama a função para lidar com a morte do jogador

func die():
	print("O jogador morreu!")
	# Reinicia o jogo a partir da cena "World.tscn"
	get_tree().change_scene("res://World.tscn")

class_name Projectile
extends Node2D

@export var speed: float = 600.0

var damage: float = 0.0
var target: Node2D = null
var sprite: Sprite2D

func setup(start_pos: Vector2, target_node: Node2D, dmg_value: float, proj_speed: float, texture: Texture2D = null) -> void:
	global_position = start_pos
	target = target_node
	damage = dmg_value
	speed = proj_speed
	
	sprite = $Sprite2D
	if texture and sprite:
		sprite.texture = texture

func _process(delta: float) -> void:
	# Se o alvo morreu no meio do caminho, o projétil se destrói
	if not is_instance_valid(target):
		queue_free()
		return

	# Movimentação em direção ao inimigo
	var direction = (target.global_position - global_position).normalized()
	global_position += direction * speed * delta
	
	# Rotaciona o projétil na direção do movimento
	rotation = direction.angle()

	# Checa acerto/colisão por proximidade (20px)
	if global_position.distance_to(target.global_position) <= 20.0:
		_on_hit()

func _on_hit() -> void:
	if is_instance_valid(target) and target.has_method("take_damage"):
		target.take_damage(damage)
	queue_free()

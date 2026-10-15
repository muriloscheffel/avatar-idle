class_name EnemyRunnerEntity
extends Node2D

var monster_data: MonsterData
var current_health: float = 50.0

var sprite: Sprite2D
var hp_bar: ProgressBar

func setup(data: MonsterData) -> void:
	monster_data = data
	current_health = monster_data.max_health if monster_data else 50.0
	
	# 1. Sprite do Inimigo / Espírito Sombrio
	sprite = Sprite2D.new()
	if monster_data and monster_data.texture:
		sprite.texture = monster_data.texture
	add_child(sprite)
	
	# 2. Barra de Vida Flutuante
	hp_bar = ProgressBar.new()
	hp_bar.custom_minimum_size = Vector2(50, 8)
	hp_bar.position = Vector2(-25, -40) # Centraliza acima do sprite
	hp_bar.show_percentage = false
	hp_bar.max_value = current_health
	hp_bar.value = current_health
	add_child(hp_bar)

func take_damage(amount: float) -> void:
	current_health -= amount
	if hp_bar:
		hp_bar.value = current_health
	
	# Feedback visual: pisca em vermelho ao tomar dano
	var tween = create_tween()
	if sprite:
		sprite.modulate = Color.RED
		tween.tween_property(sprite, "modulate", Color.WHITE, 0.1)
	
	if current_health <= 0:
		die()

func die() -> void:
	# Notifica a Arena que o inimigo foi derrotado
	var arena = get_parent().get_parent()
	if arena and arena.has_method("on_enemy_died"):
		arena.on_enemy_died(self)
	else:
		queue_free()

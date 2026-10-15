class_name ArenaRunner
extends Control

signal enemy_defeated(xp_earned: float)
signal stage_cleared

@export var scroll_speed: float = 180.0
@export var combat_range: float = 90.0

@onready var background: TextureRect = $BackgroundScroller
@onready var player_node: Node2D = $PlayerNode
@onready var enemy_queue: Node2D = $EnemyQueue

var player_data: MonsterData
var stage_data: StageData

var active_enemies: Array[Node2D] = []
var equipped_skills: Array[SkillData] = []

var is_marching: bool = true
var current_kills: int = 0

func setup_arena(p_data: MonsterData, s_data: StageData, skills: Array[SkillData] = []) -> void:
	player_data = p_data
	stage_data = s_data
	equipped_skills = skills
	current_kills = 0
	
	for skill in equipped_skills:
		skill.current_cooldown_timer = 0.0

	if stage_data and stage_data.background_texture:
		background.texture = stage_data.background_texture
		
	# Configuração para rolagem infinita no Godot 4
	background.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode = TextureRect.STRETCH_TILE

	spawn_initial_horde()

func spawn_initial_horde() -> void:
	for child in enemy_queue.get_children():
		child.queue_free()
	active_enemies.clear()
	
	if stage_data == null:
		return

	for i in range(stage_data.required_kills):
		_create_enemy_in_queue(stage_data.enemy_base, i)
		
	if stage_data.boss_base:
		_create_enemy_in_queue(stage_data.boss_base, stage_data.required_kills)

func _create_enemy_in_queue(enemy_resource: MonsterData, queue_index: int) -> void:
	# Fallback de segurança para evitar erro de null value
	if enemy_resource == null:
		enemy_resource = MonsterData.new()
		enemy_resource.name = "Espírito Sombrio"
		enemy_resource.max_health = 50.0

	var enemy_instance = Node2D.new()
	enemy_instance.set_script(load("res://scripts/combat/EnemyRunnerEntity.gd"))
	
	var spawn_x = get_viewport_rect().size.x + (queue_index * 150.0)
	enemy_instance.position = Vector2(spawn_x, player_node.position.y)
	
	enemy_queue.add_child(enemy_instance)
	enemy_instance.setup(enemy_resource.duplicate())
	active_enemies.append(enemy_instance)

func _process(delta: float) -> void:
	_process_auto_skills(delta)
	
	if not is_marching or active_enemies.is_empty():
		return

	# Rolagem do cenário por movimentação do nó com reset infinito
	background.position.x -= scroll_speed * delta
	if background.position.x <= -background.size.x:
		background.position.x = 0.0

	# Movimentação da horda
	for enemy in active_enemies:
		enemy.position.x -= scroll_speed * delta

	# Checa combate corpo a corpo
	var front_enemy = active_enemies[0]
	var dist = front_enemy.position.x - player_node.position.x
	
	if dist <= combat_range:
		is_marching = false

func _process_auto_skills(delta: float) -> void:
	if active_enemies.is_empty():
		return

	for skill in equipped_skills:
		if skill.current_cooldown_timer > 0:
			skill.current_cooldown_timer -= delta
		else:
			if _try_cast_skill(skill):
				skill.current_cooldown_timer = skill.cooldown

func _try_cast_skill(skill: SkillData) -> bool:
	var target = active_enemies[0]
	var dist = target.position.x - player_node.position.x
	
	if dist <= skill.range_distance:
		_spawn_projectile(skill, target)
		return true
		
	return false

func _spawn_projectile(skill: SkillData, target: Node2D) -> void:
	var proj_scene = preload("res://scenes/combat/Projectile.tscn")
	var proj = proj_scene.instantiate() as Projectile
	
	var base_atk = player_data.attack if player_data else 10.0
	var damage = base_atk * skill.damage_multiplier
	add_child(proj)
	proj.setup(player_node.global_position, target, damage, skill.projectile_speed, skill.projectile_texture)

func on_enemy_died(enemy: Node2D) -> void:
	active_enemies.erase(enemy)
	enemy.queue_free()
	current_kills += 1
	
	var xp = stage_data.xp_per_kill if stage_data else 10.0
	enemy_defeated.emit(xp)
	
	if active_enemies.is_empty():
		stage_cleared.emit()
	else:
		is_marching = true

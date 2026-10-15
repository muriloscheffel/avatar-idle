extends Control

@onready var arena: ArenaRunner = $Arena
@onready var right_drawer: PanelContainer = $RightDrawerPanel
@onready var panel_title: Label = $RightDrawerPanel/VBoxContainer/Header/PanelTitle
@onready var close_button: Button = $RightDrawerPanel/VBoxContainer/Header/CloseButton

@onready var map_view: Control = $RightDrawerPanel/VBoxContainer/DynamicContent/MapView
@onready var skills_view: Control = $RightDrawerPanel/VBoxContainer/DynamicContent/SkillsView
@onready var inventory_view: Control = $RightDrawerPanel/VBoxContainer/DynamicContent/InventoryView

@onready var map_btn: Button = $BottomNavigationBar/HBoxContainer/MapButton
@onready var skills_btn: Button = $BottomNavigationBar/HBoxContainer/SkillsButton
@onready var inventory_btn: Button = $BottomNavigationBar/HBoxContainer/InventoryButton

var avatar_skills: Array[SkillData] = []

func _ready() -> void:
	right_drawer.visible = false
	
	map_btn.pressed.connect(func(): open_panel("Mapa de Fases", map_view))
	skills_btn.pressed.connect(func(): open_panel("Habilidades Elementais", skills_view))
	inventory_btn.pressed.connect(func(): open_panel("Inventário", inventory_view))
	close_button.pressed.connect(close_panel)
	
	setup_avatar_demo()

func setup_avatar_demo() -> void:
	# Cria habilidades de teste dos 4 elementos
	var fireball = SkillData.new()
	fireball.name = "Bola de Fogo"
	fireball.element = SkillData.Element.FIRE
	fireball.damage_multiplier = 2.0
	fireball.cooldown = 2.5
	fireball.range_distance = 600.0

	var air_slash = SkillData.new()
	air_slash.name = "Lâmina de Vento"
	air_slash.element = SkillData.Element.AIR
	air_slash.damage_multiplier = 1.0
	air_slash.cooldown = 1.2
	air_slash.range_distance = 500.0

	avatar_skills = [fireball, air_slash]

	var avatar_data = MonsterData.new()
	avatar_data.name = "Avatar"
	avatar_data.attack = 15.0

	var stage_data = load("res://data/stages/fase_1.tres") as StageData
	if stage_data == null:
		stage_data = StageData.new()
		stage_data.required_kills = 5

	arena.setup_arena(avatar_data, stage_data, avatar_skills)

func open_panel(title: String, target_view: Control) -> void:
	panel_title.text = title
	map_view.visible = false
	skills_view.visible = false
	inventory_view.visible = false
	
	target_view.visible = true
	right_drawer.visible = true

func close_panel() -> void:
	right_drawer.visible = false

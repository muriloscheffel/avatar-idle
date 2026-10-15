class_name SkillData
extends Resource

enum Element { FIRE, WATER, EARTH, AIR }

@export var name: String = "Habilidade Elemental"
@export var element: Element = Element.FIRE
@export var damage_multiplier: float = 1.5
@export var cooldown: float = 2.0
@export var range_distance: float = 500.0
@export var projectile_speed: float = 600.0
@export var projectile_texture: Texture2D

var current_cooldown_timer: float = 0.0

class_name ShadeBlackboard
extends RefCounted

var target: Player = null
var dir: float = 1.0
var can_decide: bool = true
var damage_source: AttackArea = null

var health: float = 8.0
var max_health: float = 8.0
var distance_to_target: float = INF
var last_known_target_pos: Vector2 = Vector2.ZERO

var spawn_scene_uid: String = ""
var spawn_position: Vector2 = Vector2.ZERO

var next_jump_time: float = 0.0

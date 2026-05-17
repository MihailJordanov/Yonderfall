@icon("res://general/icons/player_sensor.svg")
class_name PlayerSensor
extends Area2D

signal player_entered
signal player_exited
signal started_searching

@export var search_duration: float = 2.0
@export var use_audio_sensor: bool = true
@export var audio_detected_dist: float = 450.0
@export var min_audio_sence: float = 0.25

var can_see_player: bool = false
var enemy: Enemy
var shade: Shade
var timer: float = 0.0


func _ready() -> void:
	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)

	if owner is Enemy:
		enemy = owner as Enemy
		enemy.direction_changed.connect(_on_direction_changed)

	elif owner is Shade:
		shade = owner as Shade
		shade.direction_changed.connect(_on_direction_changed)

	else:
		set_physics_process(false)
		monitoring = false
		return

	set_collision_mask_value(5, true)

	if use_audio_sensor:
		Audio.player_made_sound.connect(_on_player_sound)

	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _physics_process(delta: float) -> void:
	if timer > 0.0 and not can_see_player:
		timer -= delta

		if timer <= 0.0:
			player_exited.emit()
			_set_target(null)


func _on_body_entered(n: Node2D) -> void:
	if not (n is Player or n.is_in_group("Player")):
		return

	player_entered.emit()
	can_see_player = true
	timer = 0.0
	_set_target(n)


func _on_body_exited(n: Node2D) -> void:
	if not (n is Player or n.is_in_group("Player")):
		return

	started_searching.emit()
	can_see_player = false
	timer = search_duration


func _on_direction_changed(new_dir: float) -> void:
	if new_dir < 0.0:
		scale.x = -1.0
	elif new_dir > 0.0:
		scale.x = 1.0


func _on_player_sound(pos: Vector2, volume: float) -> void:
	var sound_dist: float = global_position.distance_to(pos)
	var sound_ratio: float = clampf(
		1.0 - sound_dist / audio_detected_dist,
		0.0,
		1.0
	) * 2.5

	var perceived_vol: float = volume * sound_ratio

	if perceived_vol >= min_audio_sence:
		timer = search_duration
		var player: Node = get_tree().get_first_node_in_group("Player")
		_set_target(player)


func _set_target(target: Node) -> void:
	if enemy:
		enemy.blackboard.target = target
	elif shade:
		shade.blackboard.target = target as Player

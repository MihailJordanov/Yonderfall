@icon( "res://general/icons/shade.svg" )

class_name Shade
extends CharacterBody2D

signal defeated( scene_uid: String )
signal direction_changed(new_dir: float)

@onready var sprite: Sprite2D = %Sprite2D
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var damage_area: DamageArea = %DamageArea
@onready var attack_area: AttackArea = %AttackArea
@onready var player_sensor: Area2D = %PlayerSensor
@onready var edge_sensor: Node = %EdgeSensor
@onready var wall_sensor: RayCast2D = %WallSensor
@onready var state_machine: ShadeStateMachine = %ShadeStateMachine
@onready var decision_engine: ShadeDecisionEngine = $ShadeDecisionEngine

@export var gravity: float = 980.0
@export var max_fall_velocity: float = 600.0
@export var max_hp: float = 8.0
var scene_uid: String = ""

var wall_sensor_offset_x: float = 30.0

var hp: float = 0.0
var blackboard: ShadeBlackboard = ShadeBlackboard.new()

func _ready() -> void:
	if SceneManager.current_scene_uid:
		scene_uid = SceneManager.current_scene_uid
	else:
		scene_uid = get_tree().current_scene.scene_file_path 
	
	hp = max_hp
	blackboard.health = hp
	blackboard.max_health = max_hp
	blackboard.spawn_scene_uid = scene_uid
	blackboard.spawn_position = global_position
	blackboard.dir = 1.0

	if damage_area and damage_area.has_signal("damage_taken"):
		damage_area.damage_taken.connect(_on_damage_taken)

	if wall_sensor:
		wall_sensor.position.x = wall_sensor_offset_x

	state_machine.setup(self, blackboard)
	decision_engine.setup(self, blackboard)

func _physics_process(delta: float) -> void:
	_update_target_info()

	velocity.y += gravity * delta
	velocity.y = clampf(velocity.y, -1000.0, max_fall_velocity)

	state_machine.physics_update(delta)
	move_and_slide()

	change_state(decision_engine.decide())

func change_state(new_state: ShadeState) -> void:
	state_machine.change_state(new_state)

func play_animation(anim_name: String) -> void:
	if anim_name.is_empty():
		return
	if animation_player.current_animation != anim_name:
		animation_player.play(anim_name)

func change_dir(dir: float) -> void:
	if dir == 0.0:
		return

	blackboard.dir = sign(dir)

	direction_changed.emit(blackboard.dir)

	if sprite:
		sprite.flip_h = blackboard.dir < 0.0

	if attack_area:
		attack_area.flip(blackboard.dir)

	if wall_sensor:
		wall_sensor.position.x = (
			absf(wall_sensor.position.x) * blackboard.dir
		)
		
		
func has_wall_in_front() -> bool:
	if wall_sensor and wall_sensor.is_colliding():
		return true
	return is_on_wall()

func _update_target_info() -> void:
	if blackboard.target and is_instance_valid(blackboard.target):
		blackboard.last_known_target_pos = blackboard.target.global_position
		blackboard.distance_to_target = absf(
			blackboard.target.global_position.x - global_position.x
		)
	else:
		blackboard.target = null
		blackboard.distance_to_target = INF


func _on_damage_taken(a: AttackArea) -> void:
	if state_machine.current_state is SSDeath:
		return

	hp -= a.damage
	blackboard.health = hp
	blackboard.damage_source = a

func clear_persistent_shade() -> void:
	var save_manager := get_node_or_null("/root/SaveManager")
	if save_manager and save_manager.has_method("clear_shade_for_scene"):
		save_manager.clear_shade_for_scene(scene_uid)

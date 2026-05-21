@icon("res://general/icons/enemy.svg")
class_name Vertecray
extends Node2D

enum State {
	IDLE,
	ATTACK,
	UP
}

@export var attack_range: float = 120.0
@export var x_epsilon: float = 20.0
@export var idle_wait_time: float = 2.0
@export var attack_hold_time: float = 5.0

@onready var animation_player: AnimationPlayer = $AnimationPlayer

var state: State = State.IDLE
var state_timer: float = 0.0
var player: Node2D


func _ready() -> void:
	player = get_tree().get_first_node_in_group("Player") as Node2D

	if not animation_player.animation_finished.is_connected(_on_animation_player_animation_finished):
		animation_player.animation_finished.connect(_on_animation_player_animation_finished)

	_change_state(State.IDLE)


func _process(delta: float) -> void:
	state_timer += delta

	match state:
		State.IDLE:
			if state_timer >= idle_wait_time and _can_attack_player():
				_change_state(State.ATTACK)

		State.ATTACK:
			if state_timer >= attack_hold_time:
				_change_state(State.UP)

		State.UP:
			pass


func _change_state(new_state: State) -> void:
	state = new_state
	state_timer = 0.0

	match state:
		State.IDLE:
			animation_player.play("idle")

		State.ATTACK:
			animation_player.play("attack")

		State.UP:
			animation_player.play("up")


func _can_attack_player() -> bool:
	if player == null:
		player = get_tree().get_first_node_in_group("Player") as Node2D
		if player == null:
			return false

	var same_x: bool = abs(global_position.x - player.global_position.x) <= x_epsilon
	var in_y_range: bool = abs(global_position.y - player.global_position.y) <= attack_range

	return same_x and in_y_range


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if state == State.UP and anim_name == "up":
		_change_state(State.IDLE)

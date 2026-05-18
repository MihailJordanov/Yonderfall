@icon( "res://general/icons/decision_engine.svg" ) 
class_name ShadeDecisionEngine
extends Node

@export var idle_state: ShadeState
@export var chase_state: ShadeState
@export var jump_state: ShadeState
@export var attack_state: SSAttack
@export var stun_state: ShadeState
@export var death_state: ShadeState

@export var x_epsilon: float = 8.0

var shade: Shade
var blackboard: ShadeBlackboard
var current_state: ShadeState

func setup(s: Shade, b: ShadeBlackboard) -> void:
	shade = s
	blackboard = b
	
func decide() -> ShadeState:
	if blackboard.damage_source:
		if blackboard.health <= 0:
			return death_state
		return stun_state

	if current_state is SSDeath or not blackboard.can_decide:
		return null

	if not blackboard.target:
		return idle_state

	if attack_state and attack_state.can_attack():
		return attack_state

	if attack_state and attack_state.is_in_range():
		return idle_state

	if jump_state is SSJump and jump_state.can_jump():
		return jump_state

	if _is_close_to_target_x():
		return idle_state

	return chase_state
	
func _is_close_to_target_x() -> bool:
	if not blackboard.target:
		return false

	return abs(blackboard.target.global_position.x - shade.global_position.x) <= x_epsilon

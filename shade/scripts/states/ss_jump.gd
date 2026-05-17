class_name SSJump
extends ShadeState

@export var jump_velocity: float = -450.0
@export var forward_speed: float = 95.0
@export var jump_cooldown: float = 0.65
@export var min_target_dx: float = 32.0
@export var max_target_dy: float = 96.0
@export var fall_animation_name: String = "fall"

var started_fall: bool = false

func can_jump() -> bool:
	if not blackboard.target:
		return false

	if not shade.is_on_floor():
		return false

	if Time.get_ticks_msec() * 0.001 < blackboard.next_jump_time:
		return false

	if not shade.has_wall_in_front():
		return false

	var dx : float = blackboard.target.global_position.x - shade.global_position.x
	var dy : float = blackboard.target.global_position.y - shade.global_position.y

	if sign(dx) != blackboard.dir:
		return false

	if absf(dx) < min_target_dx:
		return false

	if absf(dy) > max_target_dy:
		return false

	return true

func enter() -> void:
	started_fall = false
	blackboard.can_decide = false
	blackboard.next_jump_time = Time.get_ticks_msec() * 0.001 + jump_cooldown

	if blackboard.target:
		shade.change_dir(sign(blackboard.target.global_position.x - shade.global_position.x))

	shade.velocity.y = jump_velocity
	shade.velocity.x = blackboard.dir * forward_speed
	shade.play_animation(animation_name if animation_name else "jump")

func exit() -> void:
	blackboard.can_decide = true

func physics_update(_delta: float) -> void:
	shade.velocity.x = blackboard.dir * forward_speed

	if shade.velocity.y > 0.0 and not started_fall:
		started_fall = true
		shade.play_animation(fall_animation_name)

	if started_fall and shade.is_on_floor():
		state_machine.change_state(
			shade.decision_engine.idle_state
		)
	

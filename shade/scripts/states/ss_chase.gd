class_name SSChase
extends ShadeState

@export var chase_speed: float = 95.0

func enter() -> void:
	shade.play_animation(animation_name if animation_name else "chase")

func physics_update(_delta: float) -> void:
	var target_x: float

	if blackboard.target:
		target_x = blackboard.target.global_position.x
		blackboard.last_known_target_pos = blackboard.target.global_position
	else:
		target_x = blackboard.last_known_target_pos.x

	var dir: float = sign(target_x - shade.global_position.x)

	if dir == 0.0:
		dir = blackboard.dir

	shade.change_dir(dir)
	shade.velocity.x = dir * chase_speed

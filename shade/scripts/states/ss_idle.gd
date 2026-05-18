class_name SSIdle
extends ShadeState

func enter() -> void:
	shade.play_animation(animation_name if animation_name else "idle")
	shade.velocity.x = 0.0

	if blackboard.target:
		var dir: float = sign(
			blackboard.target.global_position.x - shade.global_position.x
		)

		
		if dir != 0.0:
			shade.change_dir(dir)

func re_enter() -> void:
	shade.velocity.x = 0.0

func physics_update(_delta: float) -> void:
	shade.velocity.x = 0.0

	if blackboard.target:
		var dir: float = sign(
			blackboard.target.global_position.x - shade.global_position.x
		)

		if dir != 0.0:
			shade.change_dir(dir)

class_name GlitchedShadeDecisionEngine
extends ShadeDecisionEngine

@export var glitch_interval_min: float = 0.5
@export var glitch_interval_max: float = 1.2
@export var glitch_distance_min: float = 70.0
@export var glitch_distance_max: float = 90.0
@export var teleport_audio : AudioStream

var glitch_timer: float = 0.0

func setup(s: Shade, b: ShadeBlackboard) -> void:
	super.setup(s, b)
	_reset_glitch_timer()

func decide() -> ShadeState:
	_try_glitch_teleport()
	return super.decide()

func _try_glitch_teleport() -> void:
	if current_state is SSDeath:
		return

	if current_state is SSAttack:
		return

	glitch_timer -= get_physics_process_delta_time()

	if glitch_timer > 0.0:
		return

	_reset_glitch_timer()

	var dir: float = blackboard.dir

	if blackboard.target:
		dir = sign(
			blackboard.target.global_position.x - shade.global_position.x
		)

		if dir == 0.0:
			dir = blackboard.dir

	shade.change_dir(dir)

	var distance: float = randf_range(
		glitch_distance_min,
		glitch_distance_max
	)

	var motion: Vector2 = Vector2(distance * dir, 0.0)

	if not shade.test_move(shade.global_transform, motion):
		shade.global_position += motion
		Audio.play_spatial_sound( teleport_audio, shade.global_position )
		
func _reset_glitch_timer() -> void:
	glitch_timer = randf_range(
		glitch_interval_min,
		glitch_interval_max
	)
	

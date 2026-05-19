class_name WhiteShadeDecisionEngine
extends ShadeDecisionEngine

@export var fade_in_audio : AudioStream
@export var fade_out_audio : AudioStream

var teleport_after_seen_min: float = 0.5
var teleport_after_seen_max: float = 1.5
var max_chase_time_before_teleport: float = 3.0
var fade_duration: float = 0.5

var vanish_wait_min: float = 1.0
var vanish_wait_max: float = 3.0

var spawn_x_min: float = 20.0
var spawn_x_max: float = 50.0
var spawn_y_offset: float = -40.0

var fade_out_animation: String = "fade_out"
var fade_in_animation: String = "fade_in"
var teleport_timer: float = 0.0
var chase_timer: float = 0.0
var is_teleporting: bool = false
var is_vanished: bool = false


func setup(s: Shade, b: ShadeBlackboard) -> void:
	super.setup(s, b)
	_reset_teleport_timer()


func decide() -> ShadeState:
	
	if blackboard.damage_source:
		if blackboard.health <= 0:
			return death_state

		blackboard.damage_source = null
		_start_teleport_sequence()
		return super.decide()

	if current_state is SSDeath:
		return super.decide()
		
	if is_vanished:
		return idle_state

	if current_state is SSAttack:
		return super.decide()

	if blackboard.target:
		teleport_timer -= get_physics_process_delta_time()

		if current_state is SSChase:
			chase_timer += get_physics_process_delta_time()
		else:
			chase_timer = 0.0

		if teleport_timer <= 0.0:
			_reset_teleport_timer()
			_start_teleport_sequence()

		if chase_timer >= max_chase_time_before_teleport:
			chase_timer = 0.0
			_reset_teleport_timer()
			_start_teleport_sequence()
	else:
		chase_timer = 0.0
		_reset_teleport_timer()

	return super.decide()


func _start_teleport_sequence() -> void:
	if is_teleporting:
		return

	if not blackboard.target:
		return

	is_teleporting = true
	_teleport_sequence()


func _teleport_sequence() -> void:
	_play_fade(fade_out_animation)

	await get_tree().create_timer(fade_duration).timeout

	if not is_instance_valid(shade):
		return

	is_vanished = true
	shade.visible = false

	await get_tree().create_timer(
		randf_range(vanish_wait_min, vanish_wait_max)
	).timeout

	if not is_instance_valid(shade):
		return

	_teleport_near_player()
	
	is_vanished = false
	shade.visible = true
	_play_fade(fade_in_animation)

	await get_tree().create_timer(fade_duration).timeout

	is_teleporting = false


func _teleport_near_player() -> void:
	if not blackboard.target:
		return

	var side: float = [-1.0, 1.0].pick_random()
	var dist: float = randf_range(spawn_x_min, spawn_x_max)

	shade.global_position = blackboard.target.global_position + Vector2(
		side * dist,
		spawn_y_offset
	)

	shade.change_dir(-side)


func _play_fade(anim_name: String) -> void:
	if shade.has_method("play_fade"):
		if anim_name == fade_out_animation:
			Audio.play_spatial_sound( fade_out_audio, shade.global_position )
		elif anim_name == fade_in_animation:
			Audio.play_spatial_sound( fade_in_audio, shade.global_position )
		
		shade.play_fade(anim_name)


func _reset_teleport_timer() -> void:
	teleport_timer = randf_range(
		teleport_after_seen_min,
		teleport_after_seen_max
	)

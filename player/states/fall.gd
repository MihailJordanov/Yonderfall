class_name PlayerStateFall extends PlayerState

@export var fall_gravity_multiplier : float = 1.165
@export var coyote_time : float = 0.125
@export var jump_buffer_time : float = 0.2
@export var audio : AudioStream

var coyole_timer : float = 0
var buffer_timer : float = 0

func init() -> void:
	pass
	
func enter() -> void:
	player.animation_player.play("jump")
	player.animation_player.pause()
	player.gravity_multiplier = fall_gravity_multiplier
	
	if player.jump_count == 0:
		player.jump_count = 1
	
	if player.previouse_state == jump or player.previouse_state == attack:
		coyole_timer = 0
	elif player.previouse_state == crouch:
		coyole_timer = 0
		player.jump_count = 1
	else:
		coyole_timer = coyote_time
	pass
	
func exit() -> void:
	player.gravity_multiplier = 1.0
	buffer_timer = 0
	pass
	
	
func handle_input( _event : InputEvent ) -> PlayerState:
	if _event.is_action_pressed( "attack" ):
		return attack
	if _event.is_action_pressed( "jump" ):
		if coyole_timer > 0:
			player.jump_count = 0
			return jump
		elif player.jump_count <= 1 and player.double_jump:
			return jump
		else:
			buffer_timer = jump_buffer_time
	return next_state


func process( _delta: float ) -> PlayerState:
	coyole_timer -= _delta
	buffer_timer -= _delta
	set_jump_frame()
	return next_state
	
func physics_process( _delta: float) -> PlayerState:
	if player.is_on_floor():
		VisualEffects.land_dust( player.global_position )
		Audio.play_spatial_sound( audio, player.global_position )
		if buffer_timer > 0:
			player.jump_count = 0
			return jump   
		return idle
	player.velocity.x = player.direction.x * player.move_speed
	return next_state
	
func set_jump_frame() -> void:
	var frame : float = remap( player.velocity.y, 0.0, player.max_fall_velocity
	, 0.5, 1.0 )
	player.animation_player.seek( frame, true )
	pass

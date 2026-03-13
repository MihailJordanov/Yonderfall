class_name PlayerStateDeath extends PlayerState

const DEATH_AUDIO = preload("uid://u0puoy0p682n")

func init() -> void:
	pass
	
func enter() -> void:
	player.animation_player.play("death")
	Audio.play_spatial_sound( DEATH_AUDIO, player.global_position )
	Audio.play_music( null )
	await player.animation_player.animation_finished
	PlayerHud.show_game_over()
	pass
	
func exit() -> void:
	pass
	
	
func handle_input( _event : InputEvent ) -> PlayerState:
	return null


func process( _delta: float ) -> PlayerState:
	return null
	
func physics_process( _delta: float) -> PlayerState:
	player.velocity.x = 0
	return null

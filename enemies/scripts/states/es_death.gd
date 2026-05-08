class_name ESDeath
extends EnemyState

@export var knockback_strength : float = 100
@export var death_audio : AudioStream

var vel_x : float = 0
var duration : float = 0
var timer : float = 0

func enter() -> void:
	enemy.play_animation( animation_name if animation_name else "death" )
	Audio.play_spatial_sound( death_audio, enemy.global_position )
	
	duration = enemy.animation.current_animation_length
	timer = 0
	
	_calc_velocity( blackboard.damage_source )
	blackboard.damage_source = null
	blackboard.can_decide = false
	
	await enemy.animation.animation_finished
	enemy.queue_free()
	pass
	
func re_enter() -> void:
	
	pass
	
	
func exit() -> void:
	
	pass


func physics_update( _delta : float ) -> void:
	timer += _delta
	enemy.velocity.x = vel_x * ( 1 - timer / duration )
	if timer >= duration:
		blackboard.can_decide = true
	pass
	
func _calc_velocity( a : AttackArea ) -> void:
	vel_x = 1
	if a.global_position.x > enemy.global_position.x:
		vel_x = -1
	vel_x *= knockback_strength
	pass

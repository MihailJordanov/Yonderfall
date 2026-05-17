class_name SSDeath
extends ShadeState

@export var knockback_strength: float = 110.0

var vel_x: float = 0.0
var duration: float = 0.0
var timer: float = 0.0

func enter() -> void:
	shade.play_animation(animation_name if animation_name else "death")

	duration = shade.animation_player.current_animation_length
	if duration <= 0.0:
		duration = 0.35

	timer = 0.0
	_calc_velocity(blackboard.damage_source)
	blackboard.damage_source = null
	blackboard.can_decide = false

	await shade.animation_player.animation_finished
	shade.clear_persistent_shade()
	shade.defeated.emit(shade.scene_uid)
	shade.queue_free()

func physics_update(delta: float) -> void:
	timer += delta
	shade.velocity.x = vel_x * (1.0 - timer / duration)

func _calc_velocity(a: AttackArea) -> void:
	vel_x = 1.0
	if a and a.global_position.x > shade.global_position.x:
		vel_x = -1.0
	vel_x *= knockback_strength

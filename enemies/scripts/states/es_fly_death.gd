class_name ESFlyDeath
extends EnemyState

@export var knockback_strength: float = 120.0
@export var knockback_up_strength: float = 80.0
@export var death_audio: AudioStream

var death_velocity: Vector2 = Vector2.ZERO
var duration: float = 0.0
var timer: float = 0.0

func enter() -> void:
	enemy.play_animation(animation_name if animation_name else "death")
	Audio.play_spatial_sound(death_audio, enemy.global_position)

	duration = enemy.animation.current_animation_length
	timer = 0.0

	_calc_velocity(blackboard.damage_source)
	blackboard.damage_source = null
	blackboard.can_decide = false

	await enemy.animation.animation_finished
	enemy.queue_free()


func re_enter() -> void:
	pass


func exit() -> void:
	pass


func physics_update(delta: float) -> void:
	timer += delta

	var t : float = clamp(timer / duration, 0.0, 1.0)
	var slowdown : float = 1.0 - t

	enemy.velocity = death_velocity * slowdown

	if timer >= duration:
		blackboard.can_decide = true


func _calc_velocity(a: AttackArea) -> void:
	var dir : Vector2 = Vector2.RIGHT

	if a:
		dir = (enemy.global_position - a.global_position).normalized()

		if dir == Vector2.ZERO:
			dir = Vector2.RIGHT

	death_velocity = dir * knockback_strength

	death_velocity.y -= knockback_up_strength

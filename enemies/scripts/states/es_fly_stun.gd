class_name ESFlyStun
extends EnemyState

@export var knockback_strength : float = 120.0
@export var stun_up_strength : float = 40.0

var stun_velocity : Vector2 = Vector2.ZERO
var duration : float = 0.0
var timer : float = 0.0

func start() -> void:
	var anim : String = animation_name if animation_name else "stun"

	if enemy.animation.current_animation == anim:
		enemy.animation.seek(0)
	else:
		enemy.play_animation(anim)

	duration = enemy.animation.current_animation_length
	timer = 0.0

	_calc_velocity(blackboard.damage_source)

	blackboard.damage_source = null
	blackboard.can_decide = false


func enter() -> void:
	start()


func re_enter() -> void:
	start()


func exit() -> void:
	blackboard.can_decide = true


func physics_update(delta : float) -> void:
	timer += delta

	var t : float = clamp(timer / duration, 0.0, 1.0)
	var slowdown : float = 1.0 - t

	enemy.velocity = stun_velocity * slowdown

	if timer >= duration:
		blackboard.can_decide = true


func _calc_velocity(a : AttackArea) -> void:
	var dir : Vector2 = Vector2.RIGHT

	if a:
		dir = (enemy.global_position - a.global_position).normalized()

		if dir == Vector2.ZERO:
			dir = Vector2.RIGHT

	stun_velocity = dir * knockback_strength

	# Леко повдигане нагоре, за да изглежда като ударен във въздуха
	stun_velocity.y -= stun_up_strength

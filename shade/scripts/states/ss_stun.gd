class_name SSStun
extends ShadeState

@export var knockback_strength: float = 110.0

var vel_x: float = 0.0
var duration: float = 0.0
var timer: float = 0.0

func _start() -> void:
	var anim := animation_name if animation_name else "stun"

	if shade.animation_player.current_animation == anim:
		shade.animation_player.seek(0.0)
	else:
		shade.play_animation(anim)

	duration = shade.animation_player.current_animation_length
	if duration <= 0.0:
		duration = 0.20

	timer = 0.0
	_calc_velocity(blackboard.damage_source)
	blackboard.damage_source = null
	blackboard.can_decide = false

func enter() -> void:
	_start()

func re_enter() -> void:
	_start()

func exit() -> void:
	blackboard.can_decide = true

func physics_update(delta: float) -> void:
	timer += delta
	shade.velocity.x = vel_x * (1.0 - timer / duration)

	if timer >= duration:
		blackboard.can_decide = true

func _calc_velocity(a: AttackArea) -> void:
	vel_x = 1.0
	if a and a.global_position.x > shade.global_position.x:
		vel_x = -1.0
	vel_x *= knockback_strength

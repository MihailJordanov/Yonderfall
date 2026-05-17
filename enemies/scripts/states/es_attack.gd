class_name ESAttack
extends EnemyState

@export var attack_range : float = 100
@export var move_speed : float = 200
@export var cooldown : float = 3.0
@export var attack_area : AttackArea
@export var attack_animations : Array[String] = ["attack"]

var timer : float = 0
var duration : float = 0
var on_cooldown : bool = false
var combo_index : int = 0

func enter() -> void:
	var anim_name : String = attack_animations[combo_index]

	enemy.play_animation(anim_name)
	duration = enemy.animation.current_animation_length

	timer = 0
	blackboard.can_decide = false
	on_cooldown = true

	enemy.velocity.x = move_speed * blackboard.dir

	if attack_area:
		attack_area.flip(blackboard.dir)

func exit() -> void:
	blackboard.can_decide = true

	combo_index += 1

	if combo_index >= attack_animations.size():
		combo_index = 0
		run_cooldown()
	else:
		on_cooldown = false

func physics_update(_delta : float) -> void:
	timer += _delta

	if timer >= duration:
		blackboard.can_decide = true

func can_attack() -> bool:
	return blackboard.distance_to_target <= attack_range and not on_cooldown

func is_in_range() -> bool:
	return blackboard.distance_to_target <= attack_range

func run_cooldown() -> void:
	await get_tree().create_timer(cooldown).timeout
	on_cooldown = false

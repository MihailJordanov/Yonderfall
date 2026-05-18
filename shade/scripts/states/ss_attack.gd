class_name SSAttack
extends ShadeState

@export var attack_range: float = 42.0
@export var attack_vertical_range: float = 24.0
@export var move_speed: float = 90.0
@export var cooldown: float = 1.4
@export var attack_animations: Array[String] = ["attack"]

@export_range(0.0, 1.0) var move_stop_ratio: float = 0.35

var timer: float = 0.0
var duration: float = 0.0
var on_cooldown: bool = false
var combo_index: int = 0
var attack_epsilon: float = 10.0

func enter() -> void:
	var anim_name: String = attack_animations[combo_index]

	if blackboard.target:
		var dir: float = sign(
			blackboard.target.global_position.x - shade.global_position.x
		)
		shade.change_dir(dir)

	shade.play_animation(anim_name)

	duration = shade.animation_player.current_animation_length
	if duration <= 0.0:
		duration = 0.35

	timer = 0.0
	on_cooldown = true
	blackboard.can_decide = false

	shade.velocity.x = move_speed * blackboard.dir


func exit() -> void:
	blackboard.can_decide = true

	combo_index += 1

	if combo_index >= attack_animations.size():
		combo_index = 0
		run_cooldown()
	else:
		on_cooldown = false

func physics_update(delta: float) -> void:
	timer += delta

	var ratio: float = 0.0
	if duration > 0.0:
		ratio = timer / duration

	if ratio < move_stop_ratio:
		shade.velocity.x = move_speed * blackboard.dir
	else:
		shade.velocity.x = 0.0

	if timer >= duration:
		blackboard.can_decide = true

func can_attack() -> bool:
		return blackboard.distance_to_target <= attack_range and not on_cooldown
	
func is_in_range() -> bool:
	return blackboard.distance_to_target <= attack_range

func run_cooldown() -> void:
	await get_tree().create_timer(cooldown).timeout
	on_cooldown = false

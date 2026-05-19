class_name StumpRoot
extends Node2D

signal root_destroyed

@export var max_hp: float  = 5

@onready var hazard_area: HazardArea = %HazardArea
@onready var damage_area: DamageArea = %DamageArea
@onready var animation_player: AnimationPlayer = %RootsAnimationPlayer

var hp: float
var dead: bool = false


func _ready() -> void:
	hp = max_hp

	damage_area.damage_taken.connect(_on_damage_taken)

	hazard_area.monitoring = false
	hazard_area.visible = false

	await _play_once("hit")

	if not dead:
		animation_player.play("idle")


func _on_damage_taken(attack_area: AttackArea) -> void:
	if dead:
		return

	var damage : float = 1

	if "damage" in attack_area:
		damage = attack_area.damage

	hp -= damage
	hp = max(hp, 0)

	damage_area.make_invulnerable(0.3)

	if hp <= 0:
		_die()


func _die() -> void:
	dead = true

	damage_area.process_mode = Node.PROCESS_MODE_DISABLED
	hazard_area.monitoring = false
	hazard_area.visible = false

	root_destroyed.emit()

	await _play_once("death")

	queue_free()


func _play_once(animation_name: String) -> void:
	animation_player.play(animation_name)
	await animation_player.animation_finished

@icon( "res://general/icons/enemy.svg" )
class_name CorruptedStump
extends CharacterBody2D

enum StumpState {
	CORRUPTED,
	FREE_LEAVES,
	FREE_NO_LEAVES
}

@export var max_hp: float = 10.0
@export var root_scene: PackedScene
@export var root_spawn_range: float = 160.0
@export var root_spawn_cooldown: float = 2.0
@export var max_roots: int = 5

@onready var damage_area: DamageArea = %DamageArea
@onready var animation_player: AnimationPlayer = %StumpAnimationPlayer

var hp: float
var state: StumpState = StumpState.CORRUPTED
var player: Player
var can_spawn_root: bool = true
var active_roots: Array[Node] = []

var has_freed_stump: bool = false
var has_lost_leaves: bool = false


func _ready() -> void:
	hp = max_hp
	player = get_tree().get_first_node_in_group("Player")

	damage_area.damage_taken.connect(_on_damage_taken)

	load_stump_state()
	_apply_state_from_hp()


func _physics_process(_delta: float) -> void:
	if state != StumpState.CORRUPTED:
		return

	if player == null:
		player = get_tree().get_first_node_in_group("Player")
		return

	active_roots = active_roots.filter(func(root): return is_instance_valid(root))

	var distance_to_player : float = global_position.distance_to(player.global_position)

	if distance_to_player <= root_spawn_range:
		_try_spawn_root()


func _try_spawn_root() -> void:
	if not can_spawn_root:
		return

	if active_roots.size() >= max_roots:
		return

	if root_scene == null:
		return

	can_spawn_root = false

	var root := root_scene.instantiate()
	get_tree().current_scene.add_child(root)

	var spawn_y : float = global_position.y

	if player.is_on_floor():
		spawn_y = player.global_position.y

	root.global_position = Vector2(
		player.global_position.x,
		spawn_y
	)

	active_roots.append(root)

	if root.has_signal("root_destroyed"):
		root.root_destroyed.connect(_on_root_destroyed.bind(root))

	await get_tree().create_timer(root_spawn_cooldown).timeout
	can_spawn_root = true


func _on_root_destroyed(root: Node) -> void:
	active_roots.erase(root)


func _on_damage_taken(attack_area: AttackArea) -> void:
	if hp <= 0 and state == StumpState.FREE_NO_LEAVES:
		_play_stun()
		return

	var damage: float = 1.0

	if "damage" in attack_area:
		damage = attack_area.damage

	hp -= damage
	hp = max(hp, 0)

	save_stump_state()
	damage_area.make_invulnerable(0.4)

	if state == StumpState.CORRUPTED and hp <= 5 and not has_freed_stump:
		await _free_stump()
		return

	if state == StumpState.FREE_LEAVES and hp <= 0 and not has_lost_leaves:
		await _lose_leaves()
		return

	_play_stun()


func _free_stump() -> void:
	has_freed_stump = true
	state = StumpState.FREE_LEAVES

	await _play_once("freeing _the_stump")
	_play_idle()


func _lose_leaves() -> void:
	has_lost_leaves = true
	state = StumpState.FREE_NO_LEAVES

	await _play_once("leaf loss")
	_play_idle()


func _play_idle() -> void:
	match state:
		StumpState.CORRUPTED:
			animation_player.play("idle_corrupted")

		StumpState.FREE_LEAVES:
			animation_player.play("idle_free_leaves")

		StumpState.FREE_NO_LEAVES:
			animation_player.play("idle_free_no_leaves")


func _play_stun() -> void:
	match state:
		StumpState.CORRUPTED:
			animation_player.play("stun_corrupted")

		StumpState.FREE_LEAVES:
			animation_player.play("stun_free_leaves")

		StumpState.FREE_NO_LEAVES:
			animation_player.play("stun_free_no_leaves")


func _play_once(animation_name: String) -> void:
	animation_player.play(animation_name)
	await animation_player.animation_finished
	
	
func get_save_key() -> String:
	return "corrupted_stump/" + unique_name()


func save_stump_state() -> void:
	SaveManager.persistent_data[get_save_key()] = {
		"hp": hp
	}

	SaveManager.write_current_save_file()


func load_stump_state() -> void:
	var data: Dictionary = SaveManager.persistent_data.get(get_save_key(), {})

	if data.is_empty():
		return

	hp = int(data.get("hp", max_hp))
	
	
func _apply_state_from_hp() -> void:
	if hp <= 0:
		hp = 0
		state = StumpState.FREE_NO_LEAVES
		has_freed_stump = true
		has_lost_leaves = true
	elif hp <= 5:
		state = StumpState.FREE_LEAVES
		has_freed_stump = true
		has_lost_leaves = false
	else:
		state = StumpState.CORRUPTED
		has_freed_stump = false
		has_lost_leaves = false

	_play_idle()
	
func unique_name() -> String:
	var u_name: String = ResourceUID.path_to_uid(owner.scene_file_path)
	u_name += "/" + get_parent().name + "/" + name
	return u_name

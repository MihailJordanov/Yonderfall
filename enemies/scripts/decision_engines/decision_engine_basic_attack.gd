class_name DecisionEngineBasicAttack
extends DecisionEngine

# Include in DecisionEngine:
# var enemy : Enemy
# current_state : EnemtState
# var blackboard : Blackboard

@export var attack_state : ESAttack
@export var chase_state : EnemyState
@export var es_idle: EnemyState
	
@onready var es_walk: ESWalk = %ESWalk
@onready var es_stun: ESStun = %ESStun
@onready var es_death: ESDeath = %ESDeath

var x_epsilon : float = 8.0

func _ready() -> void:
	await super()
	pass
	
func decide() -> EnemyState:
	
	if blackboard.damage_source:
		if blackboard.health <= 0:
			return es_death
		else:
			return es_stun
			
	if current_state is ESDeath or not blackboard.can_decide:
		return null
		
	if blackboard.target:
		if attack_state.can_attack():
			return attack_state
			
		if attack_state.is_in_range():
			return es_idle
		
		if _is_close_to_target_x():
			return es_idle
			
		return chase_state
	return es_walk
	
	
func _is_close_to_target_x() -> bool:
	if not blackboard.target:
		return false
	
	return abs(blackboard.target.global_position.x - enemy.global_position.x) <= x_epsilon
	
	
	
	
	
	
	
	
	
	
	
	

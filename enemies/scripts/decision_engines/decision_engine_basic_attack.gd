class_name DecisionEngineBasicAttack
extends DecisionEngine

# Include in DecisionEngine:
# var enemy : Enemy
# current_state : EnemtState
# var blackboard : Blackboard

@export var attack_state : ESAttack
@export var chase_state : EnemyState
	
@onready var es_walk: ESWalk = %ESWalk
@onready var es_stun: ESStun = %ESStun
@onready var es_death: ESDeath = %ESDeath
@onready var es_idle: ESIdle = %ESIdle


func _ready() -> void:
	await super()
	pass
	
func decide() -> EnemyState:
	
	if blackboard.damage_source:
		if blackboard.health <= 0:
			return es_death
		else:
			return es_stun
			
	if currer_state is ESDeath or not blackboard.can_decide:
		return null
		
	if blackboard.target:
		if attack_state.can_attack():
			return attack_state
		if attack_state.is_in_range():
			return es_idle
		return chase_state
	return es_walk
	
	
	
	
	
	
	
	
	
	
	
	
	
	

class_name DecisionEngineBasic
extends DecisionEngine

# Include in DecisionEngine:
# var enemy : Enemy
# current_state : EnemtState
# var blackboard : Blackboard
@onready var es_walk: ESWalk = %ESWalk
@onready var es_stun: ESStun = %ESStun
@onready var es_death: ESDeath = %ESDeath

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
		
	if blackboard.edge_detected:
		enemy.change_dir( -blackboard.dir )
	
	return es_walk
	
	
	
	
	
	
	
	
	
	
	
	
	
	

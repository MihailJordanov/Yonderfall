class_name DoomScribeCurse extends Node2D

var damage : float = 10.0

func _ready() -> void:
	$AnimationPlayer.animation_finished.connect( _on_animation_finished )
	pass

func _enter_tree() -> void:
	await  get_tree().process_frame
	var p : Node2D = get_tree().get_first_node_in_group( "Player" )
	if p:
		reparent( p )
	else:
		queue_free()
	self.position = Vector2( 0, -42 )
	pass


func damage_player() -> void:
	$AttackArea.activete()
	pass

func _on_animation_finished( _a : String ) -> void:
	queue_free()
	pass
	
func set_enemy( e : Enemy ) -> void:
	e.was_killed.connect( _on_enemy_killed )
	pass


func _on_enemy_killed() -> void:
	queue_free()
	pass

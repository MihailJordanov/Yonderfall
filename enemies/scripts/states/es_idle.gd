class_name ESIdle
extends EnemyState

func enter() -> void:
	enemy.play_animation(animation_name if animation_name else "idle")
	enemy.velocity.x = 0
	pass
	
func re_enter() -> void:
	pass
	
	
func exit() -> void:
	pass


func physics_update(_delta : float) -> void:
	enemy.velocity.x = 0
	pass

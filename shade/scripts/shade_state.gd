@icon( "res://player/states/state.svg" )
class_name ShadeState
extends Node

@export var animation_name: String = ""

var shade : Shade
var blackboard: ShadeBlackboard
var state_machine: ShadeStateMachine

func enter() -> void:
	pass

func re_enter() -> void:
	pass

func exit() -> void:
	pass

func physics_update(_delta: float) -> void:
	pass

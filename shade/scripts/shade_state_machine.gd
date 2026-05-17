@icon("res://general/icons/state_machine.svg")
class_name ShadeStateMachine
extends Node

var shade : Shade
var blackboard : ShadeBlackboard
var states : Array[ShadeState] = []

var current_state: ShadeState:
	get:
		return states.front() if states.size() > 0 else null

var prev_state: ShadeState:
	get:
		return states[1] if states.size() > 1 else null

func setup(s: Shade, b: ShadeBlackboard) -> void:
	shade = s
	blackboard = b
	states.clear()

	for c in get_children():
		if c is ShadeState:
			c.shade = s
			c.blackboard = b
			c.state_machine = self
			states.append(c)

	if current_state:
		current_state.enter()

func change_state(new_state: ShadeState) -> void:
	if new_state == null:
		return

	if new_state == current_state:
		current_state.re_enter()
		return

	if current_state:
		current_state.exit()

	states.push_front(new_state)

	if shade and shade.decision_engine:
		shade.decision_engine.current_state = new_state

	current_state.enter()
	states.resize(min(states.size(), 2))

func physics_update(delta: float) -> void:
	if current_state:
		current_state.physics_update(delta)

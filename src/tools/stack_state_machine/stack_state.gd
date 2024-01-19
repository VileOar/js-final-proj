## State pattern implementation
##
## base class for all game state nodes
extends Node
class_name StackState

## reference to the parent state machine
@onready var _fsm : StackStateMachine = get_parent()

## whether this state is the top of the stack
var active : bool


## base enter method which calls the custom overridable one AND base_activate()[br]
## this one should not be overriden
func base_enter():
	enter()
	base_activate()


## called when this state is pushed down the stack
func enter():
	pass


## base exit method which calls the custom overridable one AND base_deactivate()[br]
## this one should not be overriden
func base_exit():
	base_deactivate()
	exit()


## called when this state is popped from the stack
func exit():
	pass


## base activation method which calls the custom overridable one[br]
## this one should not be overriden
func base_activate():
	active = true
	activate()


## when this state becomes the top of the stack because one above it was popped[br]
func activate():
	pass


## base deactivation method which calls the custom overridable one[br]
## this one should not be overriden
func base_deactivate():
	active = false
	deactivate()


## when this state is no longer the top of the stack because a new one was pushed down
func deactivate():
	pass


# ---------------------------------------
#
# || --- SHORTCUTS FOR FSM METHODS --- ||
#
# ---------------------------------------

func push_state(state : String):
	_fsm.push_state(state)


func pop_state(pop_until : Array[String] = []):
	_fsm.pop_state(pop_until)


func replace_state(state : String, pop_until : Array[String] = []):
	_fsm.replace_state(state, pop_until)

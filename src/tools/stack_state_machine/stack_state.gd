class_name StackState
extends Node
## State pattern implementation.
##
## Base class for all game state nodes.[br]
## NOTE: this class does NOT block signals received, even when not active (top of stack). To ignore
## received signals, please check is_active() inside a signal's callback method.

## Emited when this state becomes active (top of the stack)
signal activated(name)
## Emited when this state becomes inactive (is no longer top of stack)
signal deactivated(name)

# Reference to the parent state machine.
@onready var _fsm: StackStateMachine = get_parent()

# Whether this state is the top of the stack.
var _active: bool

# Memory of what the process mode is prior to disabling.[br]
# Should only be used by _enable_node().
var _process_mem: ProcessMode


## Called when this state is pushed down the stack.
func enter() -> void:
	pass


## Called when this state is popped from the stack.
func exit() -> void:
	pass


## When this state becomes the top of the stack because one above it was popped.[br]
func activate() -> void:
	pass


## When this state is no longer the top of the stack because a new one was pushed down.
func deactivate() -> void:
	pass


## Whether the state is active (top of stack).
func is_active() -> bool:
	return _active


## Whether a new state can be pushed on top of this one.
func allow_next_state(_state: String) -> bool:
	return true


## Return the reference to the state machine.[br]
## Useful for derived classes.
func fsm() -> StackStateMachine:
	return _fsm


# ----------------------------
# || --- Friend Methods --- ||
# ----------------------------

# Custom init function.[br]
# This must only be called by FSM.[br]
# It is not in _ready to avoid using base functions, which would require child nodes to call super.
func _custom_init() -> void:
	# initialise process mode memory
	_process_mem = process_mode
	_enable_node(false)

# Base enter method which calls the custom overridable one AND _base_activate().[br]
# This one should not be overriden.
func _base_enter() -> void:
	enter()
	_base_activate()


# Base exit method which calls the custom overridable one AND _base_deactivate().[br]
# This one should not be overriden.
func _base_exit() -> void:
	exit()
	_base_deactivate()


# Base activation method which calls the custom overridable one.[br]
# This one should not be overriden.
func _base_activate() -> void:
	activate()
	_active = true
	_enable_node(true)
	activated.emit(name) # this comes AFTER enable, to ensure signals are not blocked anymore


# Base deactivation method which calls the custom overridable one.[br]
# This one should not be overriden.
func _base_deactivate() -> void:
	deactivate()
	_active = false
	deactivated.emit(name) # this comes BEFORE disable, to ensure signals are not yet blocked
	_enable_node(false)


# -----------------------------
# || --- Private Methods --- ||
# -----------------------------

# Custom function for enabling/disabling node processing.
func _enable_node(en: bool = true) -> void:
	# after deliberation, this function does NOT disable/enable signals
	# this is because there may be situations where a state may still need to receive signals even
	# if not in operation (though this should ideally not be done)
	# as such, child states should check for is_active() in their signal callbacks when appropriate
	
	if en: # enable node
		process_mode = _process_mem # return process mode to whatever it was at the start
	else: # disable node
		_process_mem = process_mode # save current process mode
		process_mode = PROCESS_MODE_DISABLED


# ---------------------------------------
# || --- Shortcuts for FSM Methods --- ||
# ---------------------------------------

## Shortcut to call push_state() on state machine.
func push_state(state: String) -> void:
	_fsm.push_state(state)


## Shortcut to call pop_state() on state machine.
func pop_state(pop_until: Array[String] = []) -> void:
	_fsm.pop_state(pop_until)


## Shortcut to call replace_state() on state machine.
func replace_state(state: String, pop_until: Array[String] = []) -> void:
	_fsm.replace_state(state, pop_until)

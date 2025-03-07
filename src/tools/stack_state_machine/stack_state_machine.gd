class_name StackStateMachine
extends Node
## Custom implementation of a stack based FSM.
##
## The state machine will push and pop states in a LIFO so that data from previous states is kept.[br]
## This is meant to use the State pattern with [StackState] nodes as direct children.[br]
## This node should have NO OTHER children, except [StackState] nodes.
## NO OTHER processing should be here other than management of the machine. Any additional
## functionality should be implemented by extending this class.[br]
## NOTE: This class does NOT remove nodes from scene tree to disable them, as they might still need
## to be processed, even if they are not at the top of the stack.
# v2.0 (2025-01-27)

## Emitted after finishing all queued operations. Identifies whether state stack is empty.
signal no_longer_busy(empty_stack)
## Emitted when any state notifies being activated.
signal state_activated(state)
## Emitted when any state notifies being deactivated.
signal state_deactivated(state)

# The set of all valid operations that can be queued.
const _queueable_operations = [
	"_pop_state",
	"_push_state",
]

## Path to node whose children are the states to use by this machine. All children of the node must
## be of type StackState. If the path is invalid, uses the direct children of the state machine
## node.
@export var _states_nodepath: NodePath

# The stack of all states pushed down; only contains the string id of the states.
var _state_stack: Array[String] = []

# Ref to the node containing the states.
var _states_holder: Node

# The queue of operations to perform.[br]
# Each value is a tuple with the operation id and the state name.
var _busy_queue: Array[Callable] = []

# Whether currently in the middle of an operation.
var _operating := false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_states_holder = self
	if has_node(_states_nodepath): # if no path was passed (default), use this machine itself, instead
		_states_holder = get_node(_states_nodepath)
	
	# setup all states
	for child in _states_holder.get_children():
		if child is StackState:
			child._custom_init()
			child.activated.connect(_state_activated)
			child.deactivated.connect(_state_deactivated)
		else:
			push_warning(
					"Node '%s' is not a StackState but is designated as such. \
					It will be ignored by state stack, but you should still remove it." % str(child.get_path())
			)


## Whether the machine is busy and still has operations pending
func is_busy() -> bool:
	return _operating or !_busy_queue.is_empty()


## Return the state node currently at the top of stack.
func current_state() -> StackState:
	return null if _state_stack.is_empty() else get_state_node(_state_stack.back())


## Return ordered array of every state in the stack, where the last element is the top of the stack.
func get_state_stack() -> Array[String]:
	return _state_stack.duplicate()


## Get the ref to the node of the state.
func get_state_node(state: String) -> StackState:
	return _states_holder.get_node(state)


## Whether the state exists
func has_state_node(state: String) -> bool:
	return _states_holder.has_node(state)


# --------------------------------
# || --- MACHINE OPERATIONS --- ||
# --------------------------------

## Push a new state down the stack, deactivating the previous head and activating the pushed one.[br]
## Returns false if invalid state.
func push_state(state: String) -> bool:
	if _can_push_state(state):
		_try_operation(_push_state, [state])
		return true
	return false


# The actual function which is performed immediately or queued for later.[br]
# Assumes that arguments are all valid if this is actually called.
func _push_state(state: String) -> void:
	var new_head = get_state_node(state)
	var old_head = current_state()
	if old_head != null:
		old_head._base_deactivate()
	
	_state_stack.push_back(state) # push down the new state identifier
	new_head._base_enter()
	
	_operation_finished()


## The head of the state stack, returning to the previous state.[br]
## Optionally pass a target state set, executing multiple pops until one of those is reached or
## stack is empty.
func pop_state(pop_until: Array[String] = []) -> bool:
	_try_operation(_pop_state, [pop_until])
	return true


# Internal pop state function.[br]
# This function must exist because pop state might need to emit the stack emptied signal; however,
# Replace state function (which also performs the same pop function) should never emit the signal
# (because, if it is replacing, it won't be empty after the operation).
func _pop_state(pop_until: Array[String] = []):
	if !_state_stack.is_empty():
	
		# always pop at least once
		while true:
			var node = current_state() # will never be null because of if statement before while
			if node != null:
				_state_stack.pop_back() # pop head
				node._base_exit()
			
			# since there's no do ... while statement, check for break inside while
			if (
					pop_until.is_empty() # if pop_until is empty, only pop once
					or _state_stack.is_empty() # pop until no more states are in stack
					or (_state_stack.back() in pop_until) # pop again until a pop state is found
			):
				# if pop_until was not empty, but stack is, it means no desired state was reached
				# so, they either don't exist or something went wrong
				if !pop_until.is_empty() and _state_stack.is_empty() and pop_until != [""]:
					push_warning("No state among %s was found. State stack was fully emptied." % str(pop_until))
				
				# one of the end conditions was reached
				break
		
		# if not empty after popping is complete, activate new head
		if !_state_stack.is_empty():
			var node = current_state()
			if node.is_active(): # sanity check
				push_error("Sanity check failed: A node that was not top of stack was already active.")
			else:
				node._base_activate()
	
	_operation_finished()


## Shorthand to pop and push in one call.
func replace_state(state: String, pop_until: Array[String] = []) -> bool:
	# if new state is not allowed, do not perform operation
	if _can_push_state(state):
		var was_busy = is_busy() # whether it was busy before this call
		# manually queue pop and push operations
		_queue_operation(_pop_state, [pop_until])
		_queue_operation(_push_state, [state])
		if !was_busy: # if machine wasn't busy
			_operation_finished() # force the next one
		return true
	return false


# ---------------------
# || --- PRIVATE --- ||
# ---------------------

# Check if current head can transition to specified new state.
func _can_push_state(state: String) -> bool:
	if has_state_node(state): # first check if state exists
		return current_state() == null or current_state().allow_next_state(state)
	else:
		push_error(
				"State Machine has no state node '%s'. \
				Add the node as a child of the state holder." % state
		)
	return false


# Execute an operation or queue it if busy.[br]
# Return false if queued.[br]
func _try_operation(fn: Callable, args: Array) -> bool:
	if !fn.get_method() in _queueable_operations:
		push_error("Invalid operation '%s' on state machine. Aborted." % fn.get_method())
		return false
	
	if is_busy():
		_operating = true
		_queue_operation(fn, args)
		return false
	else:
		_operating = true
		fn.callv(args)
		return true


# Add a new operation to the operations queue to be performed in order without overlapping.
func _queue_operation(fn: Callable, args: Array) -> void:
	_busy_queue.push_front(fn.bindv(args))


# Called when a single operation is finished to determine what to do next
func _operation_finished() -> void:
	if _busy_queue.is_empty(): # no more operations remaining
		_operating = false
		no_longer_busy.emit(_state_stack.is_empty())
	else: # otherwise, keep operating and pop from queue
		_operating = true # make sure that is still operating (important with replace_state)
		var next_op = _busy_queue.pop_back() as Callable
		next_op.call()


# ------------------------------
# || --- SIGNAL CALLBACKS --- ||
# ------------------------------

# Callback for when a new state is activated.
func _state_activated(state: String):
	state_activated.emit(state)


# Callback for when a new state is deactivated.
func _state_deactivated(state: String):
	state_deactivated.emit(state)

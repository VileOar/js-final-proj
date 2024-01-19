## my implementation of a stack based FSM, mainly for game state handling
##
## the state machine will push and pop states in a LIFO so that data from previous states is kept[br]
## this is meant to use the State pattern with nodes as states[br]
## NO OTHER processing should be here other than management of the machine[br]
extends Node
class_name StackStateMachine

## called after pop operation leaves the machine empty
signal stack_emptied

## the stack of all states pushed down; only contains the string id of the states
var state_stack : Array[String] = []


# Called when the node enters the scene tree for the first time.
func _ready():
	for child in get_children():
		child.process_mode = Node.PROCESS_MODE_DISABLED # deactivate all nodes at first


## return the state node currently at the top of stack
func current_state() -> Node:
	return null if state_stack.is_empty() else get_node(state_stack.back())


## push a new state down the stack, deactivating the previous head and activating the pushed one
func push_state(state : String):
	var new_head = get_node(state)
	if new_head != null: # if valid state name
		var old_head = current_state()
		if old_head != null:
			old_head.process_mode = Node.PROCESS_MODE_DISABLED # deactivate the previous head
			old_head.base_deactivate()
		
		new_head.process_mode = Node.PROCESS_MODE_INHERIT # activate the new head
		new_head.base_enter()
		state_stack.push_back(state) # push down the new state identifier


## the head of the state stack, returning to the previous state[br]
## optionally pass a target state set, executing multiple pops until that one of those is reached or stack is empty
func pop_state(pop_until : Array[String] = []):
	_pop_state(pop_until)
	
	if state_stack.is_empty():
		stack_emptied.emit()


## internal pop state function[br]
## this function maust exist because pop state might need to emit the stack emptied signal; however,
## replace state function (which also performs the same pop function) should never emit the signal
## (because, if it is replacing, it won't be empty after the operation)
func _pop_state(pop_until : Array[String] = []):
	var last_head = state_stack.back()
	if !state_stack.is_empty():
		if pop_until == []:
			# if no pop until is provided, pop the current head
			var node = current_state()
			if node != null:
				node.process_mode = Node.PROCESS_MODE_DISABLED # deactivate the previous head
				node.base_exit()
			state_stack.pop_back() # pop head
		else:
			# if a pop until argument was provided, will pop all states until that is the head
			while !state_stack.is_empty() and !(state_stack.back() in pop_until):
				var node = current_state()
				if node != null:
					node.process_mode = Node.PROCESS_MODE_DISABLED # deactivate the previous head
					node.base_exit()
				state_stack.pop_back() # pop head
		
		# if not empty, activate new head
		if !state_stack.is_empty() and last_head != state_stack.back():
			var node = current_state()
			node.process_mode = Node.PROCESS_MODE_INHERIT
			node.base_activate()


## shorthand to pop and push in one call
func replace_state(state : StringName, pop_until : Array[String] = []):
	_pop_state(pop_until) # call the internal pop, so that the empty stack signal is never emitted
	push_state(state)
	
	if state_stack.is_empty(): # failsafe, in case the push operation fails
		stack_emptied.emit()

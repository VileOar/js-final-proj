## state for generating a new prompt and process player input
##
## this state is responsible for generating a new prompt and waiting for input from players [br]
## has two internal states, for each player's answer
extends StackState
class_name PromptState

## array containing the registered answers from both players[br]
## a dict, in which each key is the player index and the value is a PlayerAnswer
var _player_answers := {}
## the current direction in the prompt
var _prompt = Global.Directions.NONE

var _dyad_fsm: DyadStateMachine


func activate():
	_dyad_fsm = fsm() as DyadStateMachine
	_dyad_fsm.stop_everything()
	Signals.input_player_action.connect(_on_player_input)
	_dyad_fsm.connect_disconnect_timer(true, _timeout)
	
	# reset player answers
	_dyad_fsm.reset_answers_cache()
	_player_answers.clear()
	for player in _dyad_fsm.get_dyad_players():
		_player_answers[player] = null
	
	# this state is used to generate a new prompt, so this is done on enter
	_prompt = randi_range(0, 3) as Global.Directions # generate a new dir as per those defined in Directions
	_dyad_fsm.show_prompt_ui(true, _prompt)
	_dyad_fsm.new_prompt(_prompt)
	$PromptAudio.play()


func deactivate():
	Signals.input_player_action.disconnect(_on_player_input)
	_dyad_fsm.start_stop_timer(false)
	_dyad_fsm.connect_disconnect_timer(false, _timeout)
	_dyad_fsm.write_answers(_player_answers.values())
	_dyad_fsm.show_prompt_ui(false, Global.Directions.NONE)


## callback to an input signal from the input manager[br]
func _on_player_input(player, input_event : InputEvent):
	# check if the player belongs in this dyad and has not yet answered
	if _player_answers.has(player) and _player_answers[player] == null:
		# generate new answer from input
		var answer = _get_player_action(player, input_event)
		_player_answers[player] = answer
		Signals.new_player_answer.emit(answer)
		
		# check to see how many answers were registered
		var answer_count = _count_answers()
		if answer_count == 1: # if this is the first answer, start the timer
			_dyad_fsm.start_stop_timer(true, Global.SECOND_ANSWER_TIMER)
		elif answer_count == _player_answers.size(): # if this is the last answer, process answers
			var all_right = true
			for value in _player_answers.values():
				if value == null or !value.is_correct(): # if a value is incorrect
					if value == null:
						# failsafe, if code entered this branch, it should mean that no value is null
						push_error("If you see this error, something went terribly wrong")
					all_right = false
			
			if all_right:
				push_state("RightState")
			else:
				push_state("WrongState")


## check how many answers were registered
func _count_answers() -> int:
	var count = 0
	for value in _player_answers.values():
		if value != null:
			count += 1
	return count


## callback for when timer runs out
func _timeout():
	push_state("WrongState") # automatically go to wrong state


## function to produce a player action from an input event
func _get_player_action(player : int, event : InputEvent) -> PlayerAnswer:
	var direction = -1
	var coop = true
	if event.is_action_pressed("coop_left"):
		direction = Global.Directions.LEFT
	elif event.is_action_pressed("coop_right"):
		direction = Global.Directions.RIGHT
	elif event.is_action_pressed("coop_up"):
		direction = Global.Directions.UP
	elif event.is_action_pressed("coop_down"):
		direction = Global.Directions.DOWN
	elif event.is_action_pressed("defect_left"):
		direction = Global.Directions.LEFT
		coop = false
	elif event.is_action_pressed("defect_right"):
		direction = Global.Directions.RIGHT
		coop = false
	elif event.is_action_pressed("defect_up"):
		direction = Global.Directions.UP
		coop = false
	elif event.is_action_pressed("defect_down"):
		direction = Global.Directions.DOWN
		coop = false
	
	if direction == -1:
		return null
	
	var answer = PlayerAnswer.new(player, direction, coop)
	answer.set_correct(direction == _prompt)
	
	return answer

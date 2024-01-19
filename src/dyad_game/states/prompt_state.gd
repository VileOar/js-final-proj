## state for generating a new prompt and process player input
##
## this state is responsible for generating a new prompt and waiting for input from players [br]
## has two internal states, for each player's answer
extends BaseDyadGameState
class_name PromptState

## number of registered answers
var answers = 0


func enter():
	dyad_game.stop_everything()
	InputManager.enable(true) # enable player input
	Signals.input_player_action.connect(_on_player_input)
	dyad_game.connect_timer(_timeout)
	
	answers = 0 # reset answers counter
	
	# this state is used to generate a new prompt, so this is done on enter
	var new_dir = randi_range(0, 3) # generate a new dir as per those defined in Directions
	dyad_game.set_direction_prompt(new_dir)


func exit():
	Signals.input_player_action.disconnect(_on_player_input)
	dyad_game.disconnect_timer(_timeout)


## callback to an input signal from the input manager[br]
func _on_player_input(player, input_event : InputEvent):
	if dyad_game.check_player_dyad(player): # if this input event belongs to this dyad
		# add the new action to the game
		dyad_game.add_player_choice(_get_player_action(player, input_event))
		
		if answers == 0: # if this is the first answer
			dyad_game.start_timer(Global.SECOND_ANSWER_TIMER)
		else: # if not, process answers and advance to next state
			if _process_answers():
				replace_state("RightState")
			else:
				replace_state("WrongState")


## process answers from players[br]
## returns whether there were wrong answers
func _process_answers() -> bool:
	var wrong_answers = 0
	for action in dyad_game.get_player_actions():
		# mark the answer as either right or wrong
		action.set_correct(action.direction() == dyad_game.get_direction_prompt())
		if not action.is_correct():
			wrong_answers += 1
	
	return wrong_answers == 0


## callback for when timer runs out
func _timeout():
	_process_answers() # still needs to mark the answers as rght or wrong
	replace_state("WrongState") # automatically go to wrong state


## function to produce a player action from an input event
func _get_player_action(player : int, event : InputEvent) -> PlayerAction:
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
	return PlayerAction.new(player, direction, coop)

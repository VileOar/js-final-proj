## node to control a basic CPU player
##
## this node does not have much processing[br]
## it's based on probabilities to make decisions about what and when to answer
extends Node
class_name AIPlayer

## maximum delay value before answer is submitted (dependent on Global timer, so that there is the chance for missing it
const MAX_DELAY = Global.SECOND_ANSWER_TIMER * 1.5
## chance of getting the wrong answer
const WRONG_PROB = 0.2
## chance of cooperating when answering
const COOP_PROB = 0.8

## player index
var _player_index = -1


## set the player index
func set_player(player : int) -> void:
	_player_index = player


## called by the game to notify the AI that a new prompt is ready, so the AI may answer
func on_new_prompt(prompt : int) -> void:
	var timer := get_tree().create_timer(randf() * MAX_DELAY)
	timer.timeout.connect(_on_answer_delay_finished.bind(prompt))


## callback to the answer random delay
func _on_answer_delay_finished(prompt : int) -> void:
	var directions = Global.Directions.values()
	directions.erase(prompt)
	
	# generate an input event
	var event = InputEventAction.new()
	event.pressed = true
	
	var coop = randf() < COOP_PROB # chance to cooperate
	if randf() < WRONG_PROB: # chance to get it wrong
		prompt = directions[randi() % directions.size()] # choose one of the other directions
	
	event.action = _parse_action(prompt, coop)
	
	Signals.input_player_action.emit(_player_index, event)


## parse action from direction and coop/defect
func _parse_action(direction : int, coop : bool) -> StringName:
	var answer = "coop_" if coop else "defect_"
	
	match direction:
		Global.Directions.LEFT:
			answer += "left"
		Global.Directions.RIGHT:
			answer += "right"
		Global.Directions.UP:
			answer += "up"
		Global.Directions.DOWN:
			answer += "down"
	
	return answer

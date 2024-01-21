## this node controls the prompt UI
##
## responsible for showing, possibly scrambling the requested prompt
extends MarginContainer
class_name PromptUI

## reference to the prompt UI node
@onready var _prompt = %PromptLabel as Label


## function to set the prompt to display a new prompt
func set_prompt(direction) -> void:
	# TODO: add logic to randomly scramble the UI (mismatching colours, buttons, in order to trick
	#		the player
	# TODO: change this from a label to something better
	match direction:
		Global.Directions.LEFT:
			_prompt.text = "LEFT"
		Global.Directions.RIGHT:
			_prompt.text = "RIGHT"
		Global.Directions.UP:
			_prompt.text = "UP"
		Global.Directions.DOWN:
			_prompt.text = "DOWN"
		Global.Directions.NONE:
			_prompt.text = ""

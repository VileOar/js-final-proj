## the node that controls all UI behaviour (to declutter DyadGame script)
##
## has methods for starting animations and UI stuffs
extends PanelContainer
class_name UIController

## reference to the prompt UI node
@onready var _prompt = %PromptUI as Label


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

# TODO: change these two functions
## display wrong message
func show_message(correct : bool = true):
	_prompt.text = "c o r r e c t" if correct else "w r o n g"

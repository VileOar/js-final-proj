## this node controls the prompt UI
##
## responsible for showing, possibly scrambling the requested prompt
extends MarginContainer
class_name PromptUI

## reference to the prompt UI node
@onready var _prompt = %AnimatedPrompt as Node2D


## function to set the prompt to display a new prompt
func set_prompt(direction) -> void:
	# TODO: add logic to randomly scramble the UI (mismatching colours, buttons, in order to trick
	#		the player
	# TODO: change this from a label to something better
	_prompt.visible = true
	match direction:
		Global.Directions.LEFT:
			_prompt.rotation_degrees = 180
		Global.Directions.RIGHT:
			_prompt.rotation_degrees = 0
		Global.Directions.UP:
			_prompt.rotation_degrees = -90
		Global.Directions.DOWN:
			_prompt.rotation_degrees = 90
		Global.Directions.NONE:
			_prompt.visible = false

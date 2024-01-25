## UI node which controls displaying information about a player
##
## responsible for identifying the player, revealing their answers, ...
extends MarginContainer
class_name PlayerUI

## ref to the player label
@onready var _player_label = %Identifier as Label
## ref to the answer label
@onready var _answer_label = %Answer as Label


## set the player identification
func set_player(player : int):
	_player_label.text = "Player %s" % [player + 1]


## reveal or hide the answer
func show_answer(answer : PlayerAnswer):
	if answer == null:
		_answer_label.text = "(NONE)"
	elif answer.is_correct():
		_answer_label.text = "CORRECT"
	else:
		_answer_label.text = "WRONG - %s, %s" % [answer.direction(), "cooperated" if answer.cooperated() else "defected"]


## hide the amswer
func hide_answer():
	_answer_label.text = ""

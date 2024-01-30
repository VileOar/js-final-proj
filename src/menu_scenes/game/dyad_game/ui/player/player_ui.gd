## UI node which controls displaying information about a player
##
## responsible for identifying the player, revealing their answers, ...
extends MarginContainer
class_name PlayerUI

## ref to the player label
@onready var _player_label = %Identifier as Label
## ref to the answer label
@onready var _answer = %Answer as AnimatedAnswer


## set the player identification
func set_player(player : int):
	_player_label.text = "Player %s" % [player + 1]


## reveal or hide the answer
func show_answer(answer : PlayerAnswer):
	_answer.animate_answer(answer)


## hide the amswer
func hide_answer():
	_answer.hide_answer()

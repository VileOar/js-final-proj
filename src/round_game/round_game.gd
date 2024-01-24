## node for the actual round
##
## this node can have one or two dyads and is responsible for setting them up
## and starting/stopping the games
extends Control
class_name RoundGame

## ref to the first dyad
@onready var _dyad0 = %Dyad0 as DyadGame
## ref to the second dyad
@onready var _dyad1 = %Dyad1 as DyadGame


func _ready():
	start_round() # TODO: start with some sort of sequence


## start the round
func start_round() -> void:
	_dyad0.start_dyad()
	if SharedData.is_4player_mode(): # if 4 players also start the second one
		_dyad1.start_dyad()

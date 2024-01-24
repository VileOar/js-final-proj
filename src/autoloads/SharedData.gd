## script holding the global data that remains the same between scenes
##
## at a minimum, this holds player scores (not their controls, since that is managed by the Input
## autoload), the payoff matrix and total statistics for each player
extends Node


## the total scores and statistics of each individual player
var _player_data : Dictionary

## the payoff matrix values
var _payoff_matrix

## 2 or 4 player mode (true for 4, false for 2)
var _4player = true


func _ready():
	_payoff_matrix = PayoffMatrix.new()


## set the player mode
func set_player_mode(four_or_two_player : bool) -> void:
	_4player = four_or_two_player


## get the player mode
func is_4player_mode() -> bool:
	return _4player


## reset the player data to its initial values
func reset_player_data() -> void:
	_player_data = {}
	for i in 4: # for each of the four players
		_player_data[i] = {
				"score": 0, # the score of the player
				"coop": 0, # number of times cooperated
				"defect": 0, # number of times defected
		}


## get the matrix
func get_payoff_matrix() -> PayoffMatrix:
	return _payoff_matrix

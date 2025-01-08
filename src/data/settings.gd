class_name GameSettings
extends Resource
## Resource for the game's settings
##
## This script is the data holder for the game's persistent settings (i.e. the settings that can
## persist across sessions and be saved to and loaded from a file.

## total time for a round
var round_time: float

## number of rounds in a game
var num_rounds: int

## round lose penalty multiplier
var lose_penalty_multiplier: float

## whether to show instructions screen on start
var show_instructions: bool

## the payoff matrix outcome values
var _payoff_matrix: PayoffMatrix


func _init() -> void:
	_payoff_matrix = PayoffMatrix.new()


## return settings to their default values
func reset(include_matrix: bool = false) -> void:
	round_time = 5.0#30.0
	num_rounds = 2#5
	lose_penalty_multiplier = 0.5#0.5
	
	if include_matrix:
		_payoff_matrix.reset()


## getter for matrix data
func get_matrix_data() -> PayoffMatrix:
	return _payoff_matrix

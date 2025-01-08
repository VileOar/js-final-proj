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
	show_instructions = true
	
	if include_matrix:
		_payoff_matrix.reset()


## getter for matrix data
func get_matrix_data() -> PayoffMatrix:
	return _payoff_matrix


## save function
func save() -> void:
	var config_file := ConfigFile.new()
	
	config_file.set_value("general", "round_time", round_time)
	config_file.set_value("general", "num_rounds", num_rounds)
	config_file.set_value("general", "lose_penalty_multiplier", lose_penalty_multiplier)
	config_file.set_value("general", "show_instructions", show_instructions)
	
	for outcome in Global.Outcomes.values():
		var values := _payoff_matrix.get_matrix_outcome(outcome)
		config_file.set_value("matrix", str(outcome)+"1", values[0])
		config_file.set_value("matrix", str(outcome)+"2", values[1])
	
	var error = config_file.save(Global.SETTINGS_FILEPATH)
	if error:
		push_error("Error while trying to save data: %s. Aborting." % error)


## load function
func load() -> void:
	var config_file := ConfigFile.new()
	var error = config_file.load(Global.SETTINGS_FILEPATH)
	
	if error:
		push_error("Error while trying to load data: %s. Aborting." % error)
		return
	
	round_time = config_file.get_value("general", "round_time")
	num_rounds = config_file.get_value("general", "num_rounds")
	lose_penalty_multiplier = config_file.get_value("general", "lose_penalty_multiplier")
	show_instructions = config_file.get_value("general", "show_instructions")
	
	for outcome in Global.Outcomes.values():
		var p1 = config_file.get_value("matrix", str(outcome)+"1")
		var p2 = config_file.get_value("matrix", str(outcome)+"2")
		_payoff_matrix.set_matrix_outcome(outcome, p1, p2)

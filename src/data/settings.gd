class_name GameSettings
extends Resource
## Resource for the game's settings.
##
## This script is the data holder for the game's persistent settings (i.e. the settings that can
## persist across sessions and be saved to and loaded from a file.

## Total time for a round.
var round_time: float

## Number of rounds in a game.
var num_rounds: int

## Round lose penalty multiplier.
var lose_penalty_multiplier: float

## Whether to show instructions screen on start.
var show_instructions: bool

# the payoff matrix outcome values
var _payoff_matrix: PayoffMatrix
## Matrix data containing information about decision outcomes
var payoff_matrix: PayoffMatrix:
	get:
		return _payoff_matrix
	set(_v):
		push_warning("Forbidden set operation on 'payoff_matrix'. Ignored.")

## Objects accessing the settings should not ever make any assumptions about the size of teams, even
## if obvious.
var team_size: int:
	get:
		return Global.PLAYERS_PER_TEAM
	set(_v):
		push_warning("Forbidden set operation on 'team_size'. Ignored.")


func _init() -> void:
	# TODO: pass argument for number of players
	_payoff_matrix = PayoffMatrix.new()


## Return settings to their default values.
func reset(include_matrix: bool = false) -> void:
	round_time = 5.0#30.0
	num_rounds = 2#5
	lose_penalty_multiplier = 0.5#0.5
	show_instructions = true
	
	if include_matrix:
		_payoff_matrix.reset()


## Settings save function.
func save() -> void:
	var config_file := ConfigFile.new()
	
	config_file.set_value("general", "round_time", round_time)
	config_file.set_value("general", "num_rounds", num_rounds)
	config_file.set_value("general", "lose_penalty_multiplier", lose_penalty_multiplier)
	config_file.set_value("general", "show_instructions", show_instructions)
	
	for outcome in Global.Outcomes.values():
		var values := _payoff_matrix.get_matrix_outcome(outcome)
		for ix in values.size():
			config_file.set_value("matrix", str(outcome)+str(ix+1), values[ix])
	
	var error = config_file.save(Global.SETTINGS_FILEPATH)
	if error:
		push_error("Error while trying to save data: %s. Aborting." % error)


## Settings load function.
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

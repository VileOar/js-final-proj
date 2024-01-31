## script holding the global data that remains the same between scenes
##
## at a minimum, this holds player scores (not their controls, since that is managed by the Input
## autoload), the payoff matrix and total statistics for each player
extends Node


## the total scores and statistics of each individual player
var _player_data : Array

## the payoff matrix values
var _payoff_matrix

## 2 or 4 player mode (true for 4, false for 2)
var _4player = true


func _ready():
	_payoff_matrix = PayoffMatrix.new()
	_player_data = [
		PlayerStats.new(),
		PlayerStats.new(),
		PlayerStats.new(),
		PlayerStats.new(),
	]
	reset_player_data()
	
	Signals.new_player_answer.connect(_on_new_player_answer)


## set the player mode
func set_player_mode(four_or_two_player : bool) -> void:
	_4player = four_or_two_player


## get the player mode
func is_4player_mode() -> bool:
	return _4player


## reset the player data to its initial values
func reset_player_data() -> void:
	for i in 4: # for each of the four players
		_player_data[i].reset()


## get the matrix
func get_payoff_matrix() -> PayoffMatrix:
	return _payoff_matrix


## manually set player total score
func set_player_score(player_id : int, score : int) -> void:
	if player_id >= 0 and player_id < _player_data.size():
		_player_data[player_id].set_score(score)
	else:
		assert(false, "Fatal: invalid player_id given")


## add to a player's score
func add_player_score(player_id : int, score : int) -> void:
	if player_id >= 0 and player_id < _player_data.size():
		_player_data[player_id].add_score(score)
	else:
		assert(false, "Fatal: invalid player_id given")


## get a player's score
func get_player_score(player_id : int) -> int:
	if player_id >= 0 and player_id < _player_data.size():
		return _player_data[player_id].get_score()
	else:
		assert(false, "Fatal: invalid player_id given")
		return -1


## get the PlayerStats of a player
func get_player_stats(player_id: int) -> PlayerStats:
	if player_id >= 0 and player_id < _player_data.size():
		return _player_data[player_id]
	else:
		assert(false, "Fatal: invalid player_id given")
		return null


## callback to when an answer is created, for statistics
func _on_new_player_answer(answer: PlayerAnswer) -> void:
	var stats = _player_data[answer.player_id()] as PlayerStats
	stats.parse_answer(answer)

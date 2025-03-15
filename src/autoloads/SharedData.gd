## script holding the global data that remains the same between scenes
##
## at a minimum, this holds player scores (not their controls, since that is managed by the Input
## autoload), the payoff matrix and total statistics for each player
extends Node


# the game settings
var _settings: GameSettings

# the list of dyads, where each value is a list of the players in that dyad
var _dyads: Array[Array] = []

# an array of round data; each value is a dictionary of players and their respective scores that round
var _rounds_stats: Array[Dictionary] = []


func _ready():
	_settings = GameSettings.new()
	if FileAccess.file_exists(Global.SETTINGS_FILEPATH):
		_settings.load()
	else:
		_settings.reset(true)
	
	Signals.round_published.connect(_on_round_published)


## getter for game settings
func get_settings() -> GameSettings:
	return _settings


## setup dyads and player data
func setup_dyads_playerdata(player_count) -> void:
	_dyads.clear()
	for stats in _rounds_stats:
		stats.clear()
	_rounds_stats.clear()
	
	_setup_dyad_players(player_count)


## setter for dyad amount
func _setup_dyad_players(player_count: int) -> void:
	var px = 0
	while px < player_count:
		var first_member = px
		px += _settings.team_size
		# if over the total, it means that the passed amount of players does
		# match the team size
		if px > player_count:
			push_error("FATAL: Not enough players to form a dyad. %s remained" % [player_count - px])
			get_tree().quit(1)
		
		_dyads.append(range(first_member, px)) # append an array of elements from the first up to px


## getter for dyad amount
func get_dyad_count() -> int:
	return _dyads.size()


## shorthand to get player count
func get_player_count() -> int:
	return get_dyad_count() * _settings.team_size


## get the dyads with the player indices
func get_dyads() -> Array[Array]:
	return _dyads.duplicate(true)


## get the round stats
func get_rounds_stats() -> Array[Dictionary]:
	return _rounds_stats


# callback for when a round set of stats is published
func _on_round_published(round_stats: Dictionary[int, PlayerStats]):
	# make the copy here (as opposed to in round_game)
	# because this is the place that needs this data stable
	var copy: Dictionary[int, PlayerStats] = {}
	for px in round_stats.keys():
		copy[px] = round_stats[px].duplicate()
	_rounds_stats.append(copy)

## script holding the global data that remains the same between scenes
##
## at a minimum, this holds player scores (not their controls, since that is managed by the Input
## autoload), the payoff matrix and total statistics for each player
extends Node


# TODO: remove
# the total scores and statistics of each individual player
#var _player_data: Array

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
	
	# TODO: remove
	#_player_data = [
		#PlayerStats.new(),
		#PlayerStats.new(),
		#PlayerStats.new(),
		#PlayerStats.new(),
	#]
	#reset_player_data()
	
	#Signals.new_player_answer.connect(_on_new_player_answer)
	Signals.round_published.connect(_on_round_published)


## getter for game settings
func get_settings() -> GameSettings:
	return _settings


## setup dyads and player data
func setup_dyads_playerdata(player_count) -> void:
	_setup_dyad_players(player_count)
	
	for stats in _rounds_stats:
		stats.clear()
	_rounds_stats.clear()
	# TODO: remove
	#_player_data = []
	#while _player_data.size() < get_player_count():
		#_player_data.append(PlayerStats.new())


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

# TODO: remove

## manually set player total score
#func set_player_score(player_id: int, score: int) -> void:
	## TODO: remove
	##if player_id >= 0 and player_id < _player_data.size():
		##_player_data[player_id].set_score(score)
	##else:
		##assert(false, "Fatal: invalid player_id given")
	#var stats = get_player_stats(player_id)
	#if stats != null:
		#return stats.set_score(score)
	#else:
		#push_error("Unable to read player stats. Aborting.")


## add to a player's score
#func add_player_score(player_id: int, delta: int) -> void:
	## TODO: remove
	##if player_id >= 0 and player_id < _player_data.size():
		##_player_data[player_id].add_score(delta)
	##else:
		##assert(false, "Fatal: invalid player_id given")
	#var stats = get_player_stats(player_id)
	#if stats != null:
		#return stats.add_score(delta)
	#else:
		#push_error("Unable to read player stats. Aborting.")


## get a player's score
#func get_player_score(player_id: int) -> int:
	## TODO: remove
	##if player_id >= 0 and player_id < _player_data.size():
		##return _player_data[player_id].get_score()
	##else:
		##assert(false, "Fatal: invalid player_id given")
		##return -1
	#var stats = get_player_stats(player_id)
	#if stats != null:
		#return stats.get_score()
	#else:
		#push_error("Unable to read player stats. Returning -1.")
		#return -1


## get the PlayerStats of a player
#func get_player_stats(player_id: int) -> PlayerStats:
	## TODO: remove
	##if player_id >= 0 and player_id < _player_data.size():
		##return _player_data[player_id]
	#if player_id >= 0 and player_id < get_player_count(): # if player id is within current bounds
		## the next two checks must be here, because they are about the internal workings of the
		## player data array, whose functionality should be hidden from outside scripts
		#
		## check if necessary to fix array to right size
		#var missing_entries = 0 # just to throw the warning
		#while player_id >= _player_data.size(): # if player id is valid but is not in array
			#missing_entries += 1
			#_player_data.append(PlayerStats.new())
		#if missing_entries > 0: # throw a warning if the array was not the right size, it should ideally not happen
			#push_warning("%s entries were missing in player stats. Added empty stats." % missing_entries)
		#
		## check if desired entry is valid
		#if _player_data[player_id] == null:
			#_player_data[player_id] = PlayerStats.new()
			#push_warning("Player stats of player %s was null. Initialised as empty." % player_id)
		#
		#return _player_data[player_id]
	#else:
		#push_error("Invalid player_id given. Returning null.")
		#return null


# callback to when an answer is created, for statistics
#func _on_new_player_answer(answer: PlayerAnswer) -> void:
	#if 0 <= answer.player_id() and answer.player_id() < _player_data.size():
		#var stats = _player_data[answer.player_id()] as PlayerStats
		#stats.parse_answer(answer)
	#else:
		#push_error("INTERNAL ERROR: Player id is larger than data array. Operation aborted.")


# callback for when a round set of stats is published
func _on_round_published(round_stats: Dictionary[int, PlayerStats]):
	# make the copy here (as opposed to in round_game)
	# because this is the place that needs this data stable
	var copy: Dictionary[int, PlayerStats] = {}
	for px in round_stats.keys():
		copy[px] = round_stats[px].duplicate()
	_rounds_stats.append(copy)

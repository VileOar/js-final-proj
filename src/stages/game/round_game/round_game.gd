## node for the actual round
##
## this node can have one or two dyads and is responsible for setting them up
## and starting/stopping the games
extends Control
class_name RoundGame

# internal signal for when all dyads report as stable
signal _all_dyads_stable
# internal signal to go to next round
signal _round_restarted

# TODO: remove
#@export var _end_scene : PackedScene
# dyad scene to instantiate for each dyad
@export var _dyad_scene: PackedScene
# scene to include between dyads if more than one
@export var _divider_ui_scene: PackedScene

# delay at the end of a round
const _ROUND_END_DELAY = 3.0

# ref to the 1sec timer
@onready var _timer = $SecondsTimer
# ref to the animation player for screen effects
@onready var _anim = $AnimationPlayer

# ref to the first dyad
@onready var _dyad0 = %Dyad0 as DyadGame
# ref to the second dyad
@onready var _dyad1 = %Dyad1 as DyadGame

# container for the dividers
@onready var _dividers: HBoxContainer = %Dividers
# container for dyads
@onready var _dyad_container: HBoxContainer = %DyadContainer

# ref to the end results screen
@onready var _round_results_screen = %RoundResultsSreen as RoundResultsScreen
# ref to the timer label
@onready var _timer_label = %TimerLabel
# ref to round label
@onready var _round_label: Label = %RoundLabel
# ref to the fade panel
@onready var _fade_screen: ColorRect = %FadeScreen

#region Shared Data Variables
# these variables mimic the values on settings, but are separate for convenience and stability
# during the operation of the round, these values CANNOT change, so, even if the values on the settings
# change, these won't

# total number of rounds
var _NUM_ROUNDS := 1
# total number of dyads
var _NUM_DYADS := 0
# lose penalty
var _LOSE_PENALTY := 1.0
# duration of round
var _ROUND_DUR := 0.0
# copy of matrix data
var _MATRIX_COPY: PayoffMatrix
#endregion

# count how many dyads are ready and stable
var _unstable_dyads = -1

# the actual timer variable[br]
# this acts as a counter that gets decremented every time the timer (1 sec) times out[br]
# makes it easier to update Timer UI
var _time_counter = -1

# current round counter
var _round_counter = 0

# the round's stats; these are overwritten each round[br]
# these are COMPLETELY independent from the ones from SharedData and are only useful for the round
var _round_stats := []


func _ready() -> void:
	_NUM_ROUNDS = SharedData.get_settings().num_rounds
	_NUM_DYADS = SharedData.get_dyad_count()
	_LOSE_PENALTY = SharedData.get_settings().lose_penalty_multiplier
	_ROUND_DUR = SharedData.get_settings().round_time
	_MATRIX_COPY = SharedData.get_settings().payoff_matrix.copy()
	
	_round_restarted.connect(_on_round_restarted)
	
	Signals.new_player_answer.connect(_on_new_player_answer)
	
	_setup_round()
	_reset_round()
	
	# TODO: correct order of events
	# - fade out from player select and change to this scene
	# - setup round
	#	- setup dyads
	# - ready round
	#	- fade in
	#	- ready dyads (wait for the stable of all dyads)
	# - start round
	#	- start dyads
	
	# TODO: remove
	#if SharedData.is_4player_mode():
		#_dyad1.show()
	#else:
		#_dyad1.hide()
	#
	#_setup_round()
	#
	#Signals.new_player_answer.connect(_on_new_player_answer)
	#
	#if !SharedData.is_4player_mode():
		#$Divider.hide()


func _reset_round() -> void:
	# make sure input is off
	InputManager.enable(false)
	
	# handle visuals
	_fade_screen.show()
	_round_results_screen.hide()
	
	# reset data variables
	_unstable_dyads = _NUM_DYADS
	
	# reset dyads
	for dyad_game in _dyad_container.get_children():
		dyad_game.reset_dyad()
	
	# reset round stats
	for stats in _round_stats:
		stats.reset()
	
	await _intro_round()
	_start_round()

# ---------------------
# || --- OPENING --- ||
# ---------------------

# create dyads and setup ui as necessary
func _setup_round() -> void:
	# setup dyads
	for ix in _NUM_DYADS:
		# only needs to add spacers and dividers if more than one dyad
		if _NUM_DYADS > 1:
			var spacer = _dividers.add_spacer(false)
			spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			if ix < _NUM_DYADS - 1: # if not the last dyad, add divider
				var divider = _divider_ui_scene.instantiate()
				_dividers.call_deferred("add_child", divider)
				while !divider.is_node_ready():
					await divider.ready
		
		# create and dyad games
		var dyad_game := _dyad_scene.instantiate() as DyadGame
		_dyad_container.call_deferred("add_child", dyad_game)
		while !dyad_game.is_node_ready():
			await dyad_game.ready
		dyad_game.setup_dyad(ix * 2, ix * 2 + 1)
		
		# prepare the player stats
		# add one for each player in the dyad
		_round_stats.append(PlayerStats.new())
		_round_stats.append(PlayerStats.new())


## wait for all round preparations to be complete (in-game animations like screen fade)
func _intro_round() -> void:
	_timer_label.modulate.a = 0.0
	_round_label.text = "Round %d" % (_round_counter+1)
	
	# fade in and music stop
	Global.play_music_track("") # stop music before fade in
	_anim.play('fade_in')
	await _anim.animation_finished
	if _anim.assigned_animation != 'fade_in': # sanity check
		push_warning("SANITY FAIL. Last played animation '%s' does not correspond to expected 'fade_in'." % _anim.assigned_animation)
	
	# play dyads' intros
	for dyad_game in _dyad_container.get_children():
		dyad_game = dyad_game as DyadGame
		dyad_game.intro_dyad()
	# wait for all dyads to be stable
	await _all_dyads_stable


## start the round
func _start_round() -> void:
	# start all dyads
	for dyad_game in _dyad_container.get_children():
		dyad_game.start_dyad()
	
	# play music
	Global.play_music_track("game")
	
	# start and setup timer
	_timer.start(1)
	_time_counter = _ROUND_DUR
	_timer_label.modulate.a = 1.0
	_timer_label.text = str(_time_counter)
	
	# enable input
	InputManager.enable(true)


# ---------------------
# || --- CLOSURE --- ||
# ---------------------

## stop the game and dyads
func _stop_round() -> void:
	# stop input
	InputManager.enable(false)
	
	# stop all dyads and solve points
	for dyad_game in _dyad_container.get_children():
		dyad_game.stop_dyad()
		_solve_points(dyad_game)


# show results screen and play end of round delay
func _outro_round() -> void:
	# handle the points of the round, regardless of UI
	_handle_round_scores()
	# setup round results screen
	_round_results_screen.set_point_stacks(_dyad0.get_dyad_game_points(), _dyad1.get_dyad_game_points())
	
	# wait a bit before advancing
	await get_tree().create_timer(_ROUND_END_DELAY).timeout
	
	# setup the rounds and kickoff results screen
	_round_results_screen.set_round(_round_counter, _NUM_ROUNDS - 1)
	_round_results_screen.show()
	_round_results_screen.start_point_solving(_round_stats)
	
	# NOTE: _next_round is called after the results screen button is pressed


## advance to new round, depending on current round count, may restart or advance to end screen
func _next_round():
	# play and await fade out animation
	_anim.play('fade_out')
	await _anim.animation_finished
	if _anim.assigned_animation != 'fade_out': # sanity check
		push_warning("Last played animation '%s' does not correspond to expected 'fade_out'")
	
	# decide if next round or end of game
	_round_counter += 1 # increment round counter
	if _round_counter >= _NUM_ROUNDS: # if reached the end of last round
		SceneSwitcher.switch_topscene_id("end_scene")
	else: # if not
		# restart round
		# NOTE: this is through a signal, as opposed to calling reset function to avoid going deeper
		# in the call stack every new round
		_round_restarted.emit()


# ------------------------
# || --- FUNCTIONAL --- ||
# ------------------------

## func to actually add the points to player data[br]
## this is done all at once, not sequentially, despite the interface
func _solve_points(dyad: DyadGame):
	# TODO: refactor
	var players = dyad.get_dyad_players()
	_round_stats[players[0]].set_score(0)
	_round_stats[players[1]].set_score(0)
	
	for point in dyad.get_dyad_game_points():
		var payoffs_array = _MATRIX_COPY.get_matrix_outcome(point) # get the corresponding payoffs array
		
		# add to this round's score
		_round_stats[players[0]].add_score(payoffs_array[0])
		_round_stats[players[1]].add_score(payoffs_array[1])


## add points to players, with regard to lose penalty
func _handle_round_scores() -> void:
	
	# TODO: remove
	#var p0_score = _round_stats[0].get_score()
	#var p1_score = _round_stats[1].get_score()
	#var p2_score = _round_stats[2].get_score()
	#var p3_score = _round_stats[3].get_score()
	#
	#var dyad0_score = p0_score + p1_score
	#var dyad1_score = p2_score + p3_score
	#
	#var lose_penalty = SharedData.get_settings().lose_penalty_multiplier
	#if dyad0_score != dyad1_score and SharedData.is_4player_mode():
		#if dyad0_score > dyad1_score:
			## if dyad0 wins, player 2 and 3 receive penalty to their round score
			#p2_score *= lose_penalty
			#p3_score *= lose_penalty
		#else:
			## else, player 0 and 1 do
			#p0_score *= lose_penalty
			#p1_score *= lose_penalty
	# the dyads with the highest score
	var winners = []
	var high_score = -INF
	for dyad_game in _dyad_container.get_children():
		dyad_game = dyad_game as DyadGame
		var dyad_score = 0
		# sum all of this dyad's players' scores
		for px in dyad_game.get_dyad_players():
			dyad_score += _round_stats[px].get_score()
		
		# if the current dyad has an equal or higher socre
		if winners.is_empty() or dyad_score >= high_score:
			# update high score and add dyad to winners
			high_score = dyad_score
			winners.append(dyad_game)
	
	# loop through the dyads again after knowing which ones have won
	for dyad_game in _dyad_container.get_children():
		dyad_game = dyad_game as DyadGame
		
		# players of dyads that could not equal the high score suffer a penalty
		var penalty = 1.0 if winners.has(dyad_game) else _LOSE_PENALTY
		for px in dyad_game.get_dyad_players():
			_round_stats[px].mult_score(penalty)
	
	_publish_round_scores()


# Method to handle end of round score keeping
func _publish_round_scores():
	Signals.round_published.emit(_round_stats)


# ------------------------------
# || --- SIGNAL CALLBACKS --- ||
# ------------------------------

# juts the callback for the timer, going one second at a time
func _on_seconds_timer_timeout():
	# TODO: refactor
	_time_counter -= 1
	_timer_label.text = str(_time_counter)
	if _time_counter <= 0: # if time reached end
		_on_round_end()
		
		#_dyad0.stop_dyad()
		#_dyad1.stop_dyad()
		#
		# solve points, regardless of UI
		#_solve_points(_dyad0)
		#_solve_points(_dyad1)
		#_handle_round_scores()
		#
		#_round_results_screen.set_point_stacks(_dyad0.get_dyad_game_points(), _dyad1.get_dyad_game_points())
		#
		#await get_tree().create_timer(_ROUND_END_DELAY).timeout
		#
		#_round_results_screen.set_round(_round_counter, SharedData.get_settings().num_rounds-1)
		#_round_results_screen.show()
		#_round_results_screen.start_point_solving(_round_stats)
	else: # else, keep going
		_timer.start(1)


# internal callback for when the round ends
func _on_round_end():
	_stop_round()
	_outro_round()


# for when a dyad reports being ready
func _on_dyad_stable():
	_unstable_dyads -= 1
	
	if _unstable_dyads == 0: # when all dyads are stable, notify self
		_all_dyads_stable.emit()


# callback for when round results screen 'next round' button is pressed
func _on_round_results_sreen_next_round():
	# TODO: refactor
	_next_round()


# callback to when an answer is created, for statistics
func _on_new_player_answer(answer: PlayerAnswer) -> void:
	var stats = _round_stats[answer.player_id()] as PlayerStats
	stats.parse_answer(answer)


# callback for the internal new round signal
func _on_round_restarted() -> void:
	_reset_round()

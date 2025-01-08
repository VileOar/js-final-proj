## node for the actual round
##
## this node can have one or two dyads and is responsible for setting them up
## and starting/stopping the games
extends Control
class_name RoundGame

@export var _end_scene : PackedScene

## delay at the end of a round
const ROUND_END_DELAY = 3.0

## ref to the 1sec timer
@onready var _timer = $SecondsTimer
## ref to the animation player for screen effects
@onready var _anim = $AnimationPlayer

## ref to the first dyad
@onready var _dyad0 = %Dyad0 as DyadGame
## ref to the second dyad
@onready var _dyad1 = %Dyad1 as DyadGame
## count how many dyads are ready and stable
var _unstable_dyads = -1

## ref to the end results screen
@onready var _round_results_screen = %RoundResultsSreen as RoundResultsScreen
## ref to the timer label
@onready var _timer_label = %TimerLabel
## ref to round label
@onready var _round_label: Label = %RoundLabel


## the actual timer variable[br]
## this acts as a counter that gets decremented every time the timer (1 sec) times out[br]
## makes it easier to update Timer UI
var _time_counter = -1

## current round counter
var _round = 0

## the round's stats; these are overwritten each round[br]
## these are COMPLETELY independent from the ones from SharedData and are only useful for the round
var _round_stats := [
	PlayerStats.new(),
	PlayerStats.new(),
	PlayerStats.new(),
	PlayerStats.new(),
]


func _ready():
	if SharedData.is_4player_mode():
		_dyad1.show()
	else:
		_dyad1.hide()
	
	_setup_round()
	
	Signals.new_player_answer.connect(_on_new_player_answer)
	
	if !SharedData.is_4player_mode():
		$Divider.hide()


## start the round
func _start_round() -> void:
	Global.play_music_track("")
	_time_counter = SharedData.get_settings().round_time
	_timer_label.text = str(_time_counter)
	
	_unstable_dyads = 1
	if SharedData.is_4player_mode(): # if 4 players also start the second one
		_unstable_dyads = 2
		_dyad1.ready_dyad()
	_dyad0.ready_dyad()


## finish everything, while everything is faded out and restart round or advance to end
func _cleanup_round() -> void:
	if SharedData.is_4player_mode():
		_dyad1.show()
	else:
		_dyad1.hide()
	_dyad0.reset_dyad()
	_dyad1.reset_dyad()
	
	for stats in _round_stats:
		(stats as PlayerStats).reset()
	
	_round_results_screen.hide()
	
	_setup_round()


## func actually add the points to player data[br]
## this is done all at once, not sequentially, despite the interface
func _solve_points(dyad : DyadGame):
	var players = dyad.get_dyad_players()
	_round_stats[players[0]].set_score(0)
	_round_stats[players[1]].set_score(0)
	
	for point in dyad.get_dyad_game_points():
		var payoffs_array = SharedData.get_settings().get_matrix_data().get_matrix_outcome(point) # get the corresponding payoffs array
		
		# add to this round's score
		_round_stats[players[0]].add_score(payoffs_array[0])
		_round_stats[players[1]].add_score(payoffs_array[1])


## add points to players, with regard to lose penalty
func _add_points_to_player() -> void:
	var p0_score = _round_stats[0].get_score()
	var p1_score = _round_stats[1].get_score()
	var p2_score = _round_stats[2].get_score()
	var p3_score = _round_stats[3].get_score()
	
	var dyad0_score = p0_score + p1_score
	var dyad1_score = p2_score + p3_score
	
	var lose_penalty = SharedData.get_settings().lose_penalty_multiplier
	if dyad0_score != dyad1_score and SharedData.is_4player_mode():
		if dyad0_score > dyad1_score:
			# if dyad0 wins, player 2 and 3 receive penalty to their round score
			p2_score *= lose_penalty
			p3_score *= lose_penalty
		else:
			# else, player 0 and 1 do
			p0_score *= lose_penalty
			p1_score *= lose_penalty
	
	SharedData.add_player_score(0, p0_score)
	SharedData.add_player_score(1, p1_score)
	SharedData.add_player_score(2, p2_score)
	SharedData.add_player_score(3, p3_score)


## wait for all round preparations to be complete (in-game animations like screen fade)
func _setup_round():
	_timer_label.modulate.a = 0.0
	_round_label.text = "Round %d" % (_round+1)
	Global.play_music_track("") # stop music before fade in
	_anim.play('fade_in')
	await _anim.animation_finished
	if _anim.assigned_animation != 'fade_in': # sanity check
		push_warning("Last played animation '%s' does not correspond to expected 'fade_in'")
	
	_start_round()


## advance to new round, depending on current round count, may restart or advance to end screen
func _wrapup_round():
	_anim.play('fade_out')
	await _anim.animation_finished
	if _anim.assigned_animation != 'fade_out': # sanity check
		push_warning("Last played animation '%s' does not correspond to expected 'fade_out'")
	
	_round += 1 # increment round counter
	if _round >= SharedData.get_settings().num_rounds:
		get_tree().change_scene_to_packed(_end_scene)
	else:
		_cleanup_round()


# ------------------------------
# || --- SIGNAL CALLBACKS --- ||
# ------------------------------

func _on_seconds_timer_timeout():
	_time_counter -= 1
	_timer_label.text = str(_time_counter)
	if _time_counter <= 0: # if time reached end
		
		_dyad0.stop_dyad()
		_dyad1.stop_dyad()
		
		# solve points, regardless of UI
		_solve_points(_dyad0)
		_solve_points(_dyad1)
		_add_points_to_player()
		
		_round_results_screen.set_point_stacks(_dyad0.get_dyad_game_points(), _dyad1.get_dyad_game_points())
		
		await get_tree().create_timer(ROUND_END_DELAY).timeout
		
		_round_results_screen.set_round(_round, SharedData.get_settings().num_rounds-1)
		_round_results_screen.show()
		_round_results_screen.start_point_solving(_round_stats)
	else: # else, keep going
		_timer.start(1)


## for when a dyad reports being ready
func _on_dyad_stable():
	_unstable_dyads -= 1
	
	if _unstable_dyads == 0: # when all dyads are stable, start them
		_dyad0.start_dyad()
		if SharedData.is_4player_mode(): # if 4 players also start the second one
			_dyad1.start_dyad()
		_timer.start(1)
		Global.play_music_track("game")
		_timer_label.modulate.a = 1.0


## callback for when round results screen 'next round' button is pressed
func _on_round_results_sreen_next_round():
	_wrapup_round()


## callback to when an answer is created, for statistics
func _on_new_player_answer(answer: PlayerAnswer) -> void:
	var stats = _round_stats[answer.player_id()] as PlayerStats
	stats.parse_answer(answer)

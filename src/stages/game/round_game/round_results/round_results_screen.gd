## screen displayed a the end of the round
##
## this script is in charge of solving each point accumulated in the round by this dyad and manage 
## each player's individual scores
extends MarginContainer
class_name RoundResultsScreen

## emited when the user clicks next round
signal next_round

# dyad scene to instantiate for each dyad
@export var _results_scene: PackedScene

# ref to the fsm/data holder
@onready var _results_fsm: ResultsStateMachine = %ResultsStateMachine

# ref to the container of dyad results scenes
@onready var _results_container: HBoxContainer = %ResultsContainer
# ref to the button to advance
@onready var _next_round_btn: Button = %NextRoundBtn
# ref to the label identifying current round
@onready var _round_label: Label = %RoundLabel


# similar to the round game, instantiate necessary scenes, according to the number of dyads
func setup_results(dyads: Array[Array], matrix_data: PayoffMatrix, penalty_multiplier: float) -> void:
	_results_fsm.MATRIX_DATA = matrix_data
	_results_fsm.penalty_multiplier = penalty_multiplier
	
	# setup results
	for dyad in dyads:
		# create and dyad games
		var results_dyad := _results_scene.instantiate() as DyadResultsPanel
		_results_container.call_deferred("add_child", results_dyad)
		while !results_dyad.is_node_ready():
			await results_dyad.ready
		results_dyad.setup_panel(dyad, matrix_data)
		# connect necessary signals
		results_dyad.finished_animation.connect(_results_fsm.get_state_node("AnimateStatsState").on_anim_finished)
		
		_results_fsm.dyad_panels.push_back(results_dyad)


## setup data about current round to update displays
func set_round_index(current_round: int, last: int) -> void:
	_round_label.text = "Round %d / %d" % [current_round+1, last+1]
	_next_round_btn.text = "End Results" if current_round == last else "Next Round"


## setup the results screen data
func set_round_data(round_stats: Dictionary[int, PlayerStats]):
	_results_fsm.round_stats = round_stats
	
	var top_score = 0
	var top_dyad: DyadResultsPanel = null
	for dyad in _results_container.get_children():
		dyad = dyad as DyadResultsPanel
		var px_lst = dyad.get_assigned_players() # get the player indices assigned to this panel
		var scores = []
		for px in px_lst:
			# filter to get only the playerstats assigned to this panel
			scores.push_back(round_stats[px])
		
		var zeros = []
		zeros.resize(dyad.get_assigned_players().size())
		zeros.fill(0)
		dyad.set_scores(zeros) # reset to zero
		
		# sum all scores of this dyad to get the team score
		var team_score = scores.reduce(func(accum, s): return accum + s.get_score(), 0)
		dyad.set_win_lose(false)
		dyad.set_stats(scores, team_score)
		
		# determine the winner
		if top_dyad == null or team_score > top_score:
			top_dyad = dyad
			top_score = team_score
	
	top_dyad.set_win_lose(true)


## set the point stacks[br]
## receive a dictionary, in which the keys are string keys of a merge of all respective players involved[br]
## via the global get_dyad_id function
func set_round_pointstacks(point_stacks: Dictionary[String, Array]) -> void:
	
	for dyad in _results_container.get_children():
		var key = Global.get_dyad_id(dyad.get_assigned_players())
		dyad.set_point_stack(point_stacks[key]) # only the size is necessary


## ready and stable to progress to next round
func _set_advanceable(en := true) -> void:
	_next_round_btn.disabled = !en


# ------------------------------
# || --- SIGNAL CALLBACKS --- ||
# ------------------------------

func _on_button_pressed():
	next_round.emit()

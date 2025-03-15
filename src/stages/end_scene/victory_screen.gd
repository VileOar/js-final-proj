## the screen that shows who won
##
## should also animate the points for each player
extends PanelContainer
class_name VictoryScreen

## Emited when this screen has reached a stable point
signal anim_done

# the dyad scene
@export var _dyad_score_packed: PackedScene

# ui refs
@onready var _victory_type: Label = %VictoryType
@onready var _player_win: Label = %PlayerWin

@onready var _dyad_scores: HBoxContainer = %DyadScores

@onready var _point_anim_timer: Timer = $PointAnimTimer
@onready var _anim_toggle: Timer = $AnimToggle

@onready var _point_sound: AudioStreamPlayer = $PointSound


# dictionary of player to their respective dyad score panels
var _player_to_dyad: Dictionary[int, DyadEndScore] = {}

# whether aimation is running or not
var _running := false

# animation toggle variable
var _anim_state: bool

# the list of winner indices
var _sorted_winners: Array[int] = []
# the list of dyads with winners
var _win_dyads: Array[DyadEndScore] = []


func _ready() -> void:
	
	Signals.general_input.connect(_on_general_input)


func setup(teams: Array[Array], final_scores: Dictionary[int, int]) -> void:
	for team in teams:
		var scores_of_team: Dictionary[int, int] = {}
		
		var dscore = _dyad_score_packed.instantiate() as DyadEndScore
		
		# extract the socres of the players in this dyad
		for px in team:
			scores_of_team[px] = final_scores[px]
			if _player_to_dyad.has(px):
				# sanity check, players can't be duplicated
				push_error("FATAL: duplicated player in final scores: %s. Shutting down." % px)
				get_tree().quit(1)
			# establish correspondence of each player to their dyad
			_player_to_dyad[px] = dscore
		
		_dyad_scores.add_child.call_deferred(dscore)
		while !dscore.is_node_ready():
			await dscore.ready
		# setup dyad
		dscore.setup(scores_of_team)
	
	# determine winners and win type
	_solve_victory(final_scores)


## enable the win indicator
func show_victory() -> void:
	var win_type = Global.WinType.PLAYER
	for dscore in _win_dyads:
		var vic = dscore.set_winners(_sorted_winners)
		win_type = max(win_type, vic)
	
	match win_type:
		Global.WinType.PLAYER:
			_victory_type.text = "PLAYER VICTORY"
		Global.WinType.TEAM:
			_victory_type.text = "TEAM VICTORY"
		Global.WinType.PERFECT:
			_victory_type.text = "PERFECT VICTORY"
	
	var pwin_message = ""
	for i in _sorted_winners.size():
		if i != 0:
			pwin_message += ", "
		pwin_message += str(_sorted_winners[i] + 1)
	if _sorted_winners.size() == 1:
		_player_win.text = "Player " + pwin_message + " WINS!"
	else:
		_player_win.text = "Players " + pwin_message + " WIN!"


## start the animation
func start_animation() -> void:
	await get_tree().create_timer(0.5).timeout
	
	_running = true
	_point_anim_timer.start()


## skip the point animation
func _skip_animation() -> void:
	_running = false
	_point_anim_timer.stop()
	_increment_point(true)


## advance a tick in the point increment (or skip
func _increment_point(skip_to_end) -> void:
	_point_sound.play()
	var all_done = true
	for dscore in _dyad_scores.get_children():
		var ddone = dscore.increment_point(skip_to_end)
		all_done = all_done && ddone
	
	if all_done:
		_end_animation()


## the function to end the animation process
func _end_animation() -> void:
	_running = false
	_point_anim_timer.stop()
	await get_tree().create_timer(0.5).timeout
	anim_done.emit()


## set the victory type on the labels
func _solve_victory(final_scores: Dictionary[int, int]) -> void:
	var new_winners: Array[int] = []
	new_winners = final_scores.keys()
	# sort the players by their individual scores
	new_winners.sort_custom(func(a, b):
			return final_scores[a] >= final_scores[b]
	)
	
	var top_score = final_scores[new_winners[0]] # the top score
	
	# determine victory type
	_win_dyads.clear()
	
	_sorted_winners.clear()
	var possible_winners: Array[int] = []
	for px in new_winners:
		var score = final_scores[px]
		var d = _player_to_dyad[px]
		
		if score == top_score:
			_sorted_winners.append(px) # the players that managed to equal the high score
		elif _win_dyads.has(d) and _win_dyads.size() <= 1 and _dyad_scores.get_child_count() > 1:
			# the moment a player does not match the highscore, but as long as only one dyad wins,
			# only the team victory is possible
			# only applicable if more than one dyad
			possible_winners.append(px) # the players that may also win, as long as only one dyad wins
		else:
			# the moment a player cannot match the highscore, either a perfect win or player win
			# special case if only one dyad
			break # if a player could not match the high score and players from different dyads win, stop
		
		# if the loop got this far, it means the player has met any of the win conditions
		if !_win_dyads.has(d):
			_win_dyads.append(d)
	
	if _win_dyads.size() <= 1:
		# if only one dyad won, any players that could not match the highscore, but belong to the
		# winning dyad, also win
		_sorted_winners.append_array(possible_winners)


# ------------------------------
# || --- SIGNAL CALLBACKS --- ||
# ------------------------------

func _on_anim_toggle_timeout() -> void:
	_anim_state = !_anim_state
	
	var label_theme = "EndLabel"
	var toggle_delay = 0.1
	var flash = false
	if _anim_state:
		label_theme = "EndLabelAnimate"
		toggle_delay = 0.2
		flash = true
	
	_victory_type.theme_type_variation = label_theme
	_player_win.theme_type_variation = label_theme
	_anim_toggle.start(toggle_delay)
	for dscore in _dyad_scores.get_children():
		dscore.set_flash(flash)


func _on_point_anim_timer_timeout() -> void:
	if _running:
		_increment_point(false)
		_point_anim_timer.start()


func _on_general_input(_event) -> void:
	if _running:
		_skip_animation()

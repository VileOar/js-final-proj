## the screen that shows who won
##
## should also animate the points for each player
extends PanelContainer
class_name VictoryScreen

# ui refs
@onready var _victory_type: Label = %VictoryType
@onready var _player_win: Label = %PlayerWin

@onready var _anim_toggle: Timer = $AnimToggle

@onready var _score_graphs: Array = %ScoreGraphs.get_children()

## ref to all player stats
var _player_stats : Array

## animation toggle variable
var _anim_state : bool

## animation counter for scores
var _scores_finished := 0

# for determining winners
var player_ids := range(4)

var first = -1
var second = -1


func _ready() -> void:
	Global.play_music_track("")
	
	# TODO: remove
	#_player_stats = [
		#SharedData.get_player_stats(0),
		#SharedData.get_player_stats(1),
		#SharedData.get_player_stats(2),
		#SharedData.get_player_stats(3),
	#]
	
	# sort indices by score
	player_ids.sort_custom(func(a, b): return _player_stats[a].get_score() > _player_stats[b].get_score())
	first = player_ids[0]
	second = player_ids[1]
	
	# set up scores
	for i in _score_graphs.size():
		var child = _score_graphs[i]
		child.setup(i, _player_stats[i].get_score(), _player_stats[first].get_score())
		child.show_winner(false)
		(child as PlayerEndScore).finished_animation.connect(_on_score_animation_finished)
	
	
	await  get_tree().create_timer(0.5).timeout
	_start_animation()


## trigger animation
func _start_animation() -> void:
	_scores_finished = 0
	
	for child in _score_graphs:
		child.start_animation()


## set the victory type on the labels
func _set_victory_type() -> void:
	Global.play_music_track("end")
	
	# team victory
	if first + second == 1 or first + second == 5: # first and second place are from the same team
		if _player_stats[first].get_score() == _player_stats[second].get_score(): # perfect victory
			_victory_type.text = "PERFECT VICTORY"
		else: # just team victory
			_victory_type.text = "TEAM VICTORY"
		_player_win.text = "TEAM %s and %s WINS!" % [first + 1, second + 1]
		
		_score_graphs[first].show_winner(true)
		_score_graphs[second].show_winner(true)
	else:
		_victory_type.text = "INDIVIDUAL VICTORY"
		_player_win.text = "PLAYER %s WINS!" % [first + 1]
		
		_score_graphs[first].show_winner(true)


# ------------------------------
# || --- SIGNAL CALLBACKS --- ||
# ------------------------------

func _on_anim_toggle_timeout() -> void:
	_anim_state = !_anim_state
	if _anim_state:
		_victory_type.theme_type_variation = "EndLabel"
		_player_win.theme_type_variation = "EndLabel"
		_anim_toggle.start(0.1)
		for child in _score_graphs:
			child.set_flash(false)
	else:
		_victory_type.theme_type_variation = "EndLabelAnimate"
		_player_win.theme_type_variation = "EndLabelAnimate"
		_anim_toggle.start(0.2)
		for child in _score_graphs:
			child.set_flash(true)


func _on_score_animation_finished() -> void:
	_scores_finished += 1
	if _scores_finished == _score_graphs.size():
		await get_tree().create_timer(0.5).timeout
		_set_victory_type()

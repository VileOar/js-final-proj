extends MarginContainer
class_name DyadEndScore

const NORMAL_COLOUR = "ff9166"
const FLASH_COLOUR = "ffe478"

@export var _player_score_packed: PackedScene

@onready var _player_scores: HBoxContainer = %PlayerScores
@onready var _outer_panel: ColorRect = %OuterPanel
@onready var _team_score_label: Label = %TeamScoreLabel

# the players in this dyad
var _players: Array[int]

var _player_dict: Dictionary[int, PlayerEndScore]


## setup this dyad with the indices of players
func setup(player_final_scores: Dictionary[int, int]) -> void:
	_players = player_final_scores.keys()
	
	# create and setup players
	for px in _players:
		var pscore := _player_score_packed.instantiate() as PlayerEndScore
		_player_scores.add_child.call_deferred(pscore)
		while !pscore.is_node_ready():
			await pscore.ready
		pscore.setup(px, player_final_scores[px])
		
		_player_dict[px] = pscore


## pass the winner list and, if any exist in this dyad, flag them
func set_winners(winner_players: Array[int]) -> int:
	var same_score = true
	var last_score = NAN
	var all_win = true
	_outer_panel.hide()
	for px in _player_dict.keys():
		
		# determine is all have the same score
		var score = _player_dict[px].get_current_score()
		if is_nan(float(last_score)):
			last_score = score
		elif last_score != score:
			same_score = false
		
		if winner_players.has(px):
			_player_dict[px].show_winner(true)
		else:
			all_win = false
	
	# if all players win, instead, hide their wins and show the team win
	if all_win:
		for pscore in _player_dict.values():
			pscore.show_winner(false)
		_outer_panel.show()
		
		if same_score:
			return Global.WinType.PERFECT
		else:
			return Global.WinType.TEAM
	
	return Global.WinType.PLAYER


## set the flash of any active win effect (called externally, so that it can be synchronised)
func set_flash(flash: bool) -> void:
	var col := Color(FLASH_COLOUR if flash else NORMAL_COLOUR)
	for pscore in _player_scores.get_children():
		pscore.set_flash(col)
	_outer_panel.color = col


## increment a new point in the point animation (called externally, so that it can be synchronised
## returns true if all children finished
func increment_point(skip_to_end: bool = false) -> bool:
	var all_done = true
	var sum = 0
	for pscore in _player_scores.get_children():
		if !pscore.is_point_done():
			var pdone = pscore.increment_point(skip_to_end)
			# if at least one is still going, return false
			all_done = all_done && pdone
		sum += pscore.get_current_score()
	
	_team_score_label.text = str(sum)
	
	return all_done

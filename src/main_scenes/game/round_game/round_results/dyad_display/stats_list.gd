## only to display and animate stats
extends MarginContainer
class_name StatsList

signal finished_animation

const WIN_COlOUR = "ffe478"
const LOSE_COLOUR = "66ffe3"

# refs to stat labels
@onready var _stat_values: GridContainer = %StatValues
@onready var _answered_stat0: Label = %AnsweredStat0
@onready var _correct_stat0: Label = %CorrectStat0
@onready var _coop_stat0: Label = %CoopStat0
@onready var _answered_stat1: Label = %AnsweredStat1
@onready var _correct_stat1: Label = %CorrectStat1
@onready var _coop_stat1: Label = %CoopStat1

@onready var _score_row: HBoxContainer = %ScoreRow
@onready var _score_stat: Label = %ScoreStat

@onready var _win_lose_label: Label = %WinLoseLabel


## reset everything
func reset() -> void:
	# hide everything
	for child in _stat_values.get_children():
		child.modulate.a = 0.0
	_score_row.modulate.a = 0.0
	_win_lose_label.text = ""


## set the stats for this player, in this round[br]
## animation to show them with delays
func animate_stats(stats0: PlayerStats, stats1: PlayerStats, score: int) -> void:
	_answered_stat0.text = str(stats0.get_answer_count())
	_answered_stat1.text = str(stats1.get_answer_count())
	_correct_stat0.text = "%s (%d%%)" % [stats0.get_correct_count(), stats0.get_correct_ratio()]
	_correct_stat1.text = "%s (%d%%)" % [stats1.get_correct_count(), stats1.get_correct_ratio()]
	_coop_stat0.text = "%s (%d%%)" % [stats0.get_coop_count(), stats0.get_coop_ratio()]
	_coop_stat1.text = "%s (%d%%)" % [stats1.get_coop_count(), stats1.get_coop_ratio()]
	_score_stat.text = str(score)
	
	# the index of the first element of the row in StatValues node
	var stat_row = 0
	while stat_row < _stat_values.get_child_count():
		await get_tree().create_timer(0.4).timeout
		_stat_values.get_child(stat_row).modulate.a = 1.0
		_stat_values.get_child(stat_row + 1).modulate.a = 1.0 # the second one is the value label
		_stat_values.get_child(stat_row + 2).modulate.a = 1.0
		
		stat_row += 3
	
	await get_tree().create_timer(0.6).timeout
	_score_row.modulate.a = 1.0
	
	finished_animation.emit()


func set_win_lose(win_lose: bool) -> void:
	if win_lose:
		_win_lose_label.text = "WIN"
		_win_lose_label.add_theme_color_override("font_color", Color(WIN_COlOUR))
	else:
		_win_lose_label.text = "LOSE"
		_win_lose_label.add_theme_color_override("font_color", Color(LOSE_COLOUR))

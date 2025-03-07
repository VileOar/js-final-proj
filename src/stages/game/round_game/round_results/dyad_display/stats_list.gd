## only to display and animate stats
## NOTE: This node assumes 2 players per dyad.
extends MarginContainer
class_name StatsList

signal finished_animation

const WIN_COlOUR = "ffe478"
const LOSE_COLOUR = "66ffe3"

# refs to stat labels
@onready var _answered_stat0: Label = %AnsweredStat0
@onready var _correct_stat0: Label = %CorrectStat0
@onready var _coop_stat0: Label = %CoopStat0
@onready var _answered_stat1: Label = %AnsweredStat1
@onready var _correct_stat1: Label = %CorrectStat1
@onready var _coop_stat1: Label = %CoopStat1

@onready var _score_stat: Label = %ScoreStat

@onready var _win_lose_label: Label = %WinLoseLabel

@onready var _animation_player: AnimationPlayer = $AnimationPlayer


## reset everything
func reset() -> void:
	_animation_player.play("RESET")


## sets the stats from the received variable.[br]
## assumes that the stats are ordered correctly
func set_stats(stats: Array[PlayerStats], score: int) -> void:
	var stats0 = stats[0]
	var stats1 = stats[1]
	_answered_stat0.text = str(stats0.get_answer_count())
	_answered_stat1.text = str(stats1.get_answer_count())
	_correct_stat0.text = "%s (%d%%)" % [stats0.get_correct_count(), stats0.get_correct_ratio()]
	_correct_stat1.text = "%s (%d%%)" % [stats1.get_correct_count(), stats1.get_correct_ratio()]
	_coop_stat0.text = "%s (%d%%)" % [stats0.get_coop_count(), stats0.get_coop_ratio()]
	_coop_stat1.text = "%s (%d%%)" % [stats1.get_coop_count(), stats1.get_coop_ratio()]
	_score_stat.text = str(score)


## set the stats for this player, in this round[br]
## animation to show them with delays
func animate_stats() -> void:
	_animation_player.play("display_stats")


func set_win_lose(win_lose: bool) -> void:
	if win_lose:
		_win_lose_label.text = "WIN"
		_win_lose_label.add_theme_color_override("font_color", Color(WIN_COlOUR))
	else:
		_win_lose_label.text = "LOSE"
		_win_lose_label.add_theme_color_override("font_color", Color(LOSE_COLOUR))


func skip_animation() -> void:
	_animation_player.play("display_stats")
	_animation_player.seek(_animation_player.current_animation_length, true)


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "display_stats":
		finished_animation.emit()

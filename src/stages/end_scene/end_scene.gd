extends Control
class_name EndScene


@onready var _victory_screen: VictoryScreen = %VictoryScreen
@onready var _stats_screen: StatsScreen = %StatsScreen

@onready var _exit_btn: Button = %ExitBtn
@onready var _stats_btn: Button = %StatsBtn


func _ready() -> void:
	Global.play_music_track("")
	
	var teams := SharedData.get_dyads()
	var rounds_stats := SharedData.get_rounds_stats()
	var final_scores: Dictionary[int, int] = {}
	
	for round_list in rounds_stats:
		for px in round_list.keys():
			var pstats := round_list[px] as PlayerStats
			final_scores[px] = final_scores.get_or_add(px, 0) + pstats.get_score()
	
	await _victory_screen.setup(teams, final_scores)
	_victory_screen.start_animation()
	_stats_screen.setup(rounds_stats)


func _on_victory_screen_anim_done() -> void:
	Global.play_music_track("end")
	_exit_btn.disabled = false
	_stats_btn.disabled = false
	_victory_screen.show_victory()


func _on_exit_btn_pressed() -> void:
	SceneSwitcher.switch_topscene_id("title_screen")


func _on_stats_btn_pressed() -> void:
	if _victory_screen.visible:
		_victory_screen.hide()
		_stats_screen.show()
	else:
		_victory_screen.show()
		_stats_screen.hide()

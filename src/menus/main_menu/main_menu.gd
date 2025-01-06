## title screen scene
extends Control


func _ready() -> void:
	Global.play_music_track("title")


func _on_quit_btn_pressed() -> void:
	get_tree().quit()


func _on_options_btn_pressed() -> void:
	SceneSwitcher.switch_topscene_id("options_scene")


func _on_start_btn_pressed() -> void:
	SceneSwitcher.switch_topscene_id("player_select")

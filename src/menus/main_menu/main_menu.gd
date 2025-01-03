## title screen scene
extends Control


@export var _matrix_scene_path: String
@export var _game_scene_path: String

@onready var _credits: PanelContainer = %Credits


func _ready() -> void:
	Global.play_music_track("title")


func _on_quit_btn_pressed() -> void:
	get_tree().quit()


func _on_matrix_btn_pressed() -> void:
	#get_tree().change_scene_to_file(_matrix_scene_path)
	SceneSwitcher.switch_topscene_id("matrix_editor")


func _on_start_btn_pressed() -> void:
	#get_tree().change_scene_to_file(_game_scene_path)
	SceneSwitcher.switch_topscene_id("player_select")


func _on_credits_btn_pressed() -> void:
	_credits.show()


func _on_back_btn_pressed() -> void:
	_credits.hide()

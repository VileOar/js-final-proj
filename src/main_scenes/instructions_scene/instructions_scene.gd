## scene for the instructions screen presented before the game
extends Control


@export var _game_scene : PackedScene

@onready var _pages: Array = %Pages.get_children()
@onready var _page_btn: Button = %PageBtn

var _current_page = 0


func _ready() -> void:
	%Answer1.force_animation(Global.Directions.RIGHT, false, true)
	%Answer2.force_animation(Global.Directions.RIGHT, false, false)


func _on_page_btn_pressed() -> void:
	_current_page = (_current_page + 1) % _pages.size()
	for page in _pages.size():
		if page == _current_page:
			_pages[page].show()
		else:
			_pages[page].hide()
	_page_btn.text = "Next Page" if _current_page == 0 else "Previous Page"


func _on_start_btn_pressed() -> void:
	get_tree().change_scene_to_packed(_game_scene)

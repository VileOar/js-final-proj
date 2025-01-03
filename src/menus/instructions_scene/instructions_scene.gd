## scene for the instructions screen presented before the game
extends Control

@onready var _pages: MarginContainer = %Pages
@onready var _page_counter: Label = %PageCounter


var _current_page = 0


func _ready() -> void:
	%Answer1.force_animation(Global.Directions.RIGHT, false, true)
	%Answer2.force_animation(Global.Directions.RIGHT, false, false)
	
	_set_page(0)


func _set_page(pagenum: int) -> void:
	var pagesize = _pages.get_child_count()
	if pagenum >= 0 && pagenum < pagesize:
		for ix in pagesize:
			var page = _pages.get_child(ix)
			if ix == pagenum:
				page.show()
			else:
				page.hide()
		
		_page_counter.text = "%d / %d" % [pagenum + 1, pagesize]
		_current_page = pagenum


func _on_page_turner_pressed(rightleft: bool) -> void:
	_set_page(_current_page + (1 if rightleft else -1))

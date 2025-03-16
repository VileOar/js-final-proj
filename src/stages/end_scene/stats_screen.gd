extends PanelContainer
class_name StatsScreen


@onready var _plot_viewer: MarginContainer = %PlotViewer


# the maximum value among all answer-based stats
var _max_y: int = 0
# the minimum value among all answer-based stats
var _min_y: int = 0

#region values to make it easier to draw on the plot

#endregion


func _process(delta: float) -> void:
	queue_redraw()
	print_debug("hello?")


## receive the array of round_stats
func setup(rounds_stats: Array[Dictionary]) -> void:
	pass


# get the appropriate stat
func _get_player_stat(player_index: int, stat: String):
	pass


func _draw() -> void:
	# rect of the plot viewer
	var plot_rect: Rect2 = _plot_viewer.get_rect()
	plot_rect = Rect2(48, 32, 1, 1)
	print_debug(plot_rect)
	
	draw_circle(plot_rect.position, 8, Color.RED)
	draw_string(ThemeDB.fallback_font, plot_rect.position + Vector2.UP * 16, "test", HORIZONTAL_ALIGNMENT_RIGHT)

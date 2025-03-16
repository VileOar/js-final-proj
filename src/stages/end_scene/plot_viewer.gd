extends MarginContainer
class_name PlotViewer


const DEFAULT_COLOR: Color = Color.WHITE

@onready var _font := ThemeDB.fallback_font
var _font_size: int = 12
var _string_width: int = _font_size * 3


var _min_y: float = 0.0
var _max_y: float = 1.0
var _max_x: float = 5

# a dictionary of plots
# each entry is a category of plots, identified by id (also a dictionary)
# each entry of that is an Array of values, corresponding to the y-values to plot
# these y-values are given as percentages, where 1 is the highest value visually possible in the plot
var _plots: Dictionary[String, Dictionary] = {}
# the colour to draw all plots of the selected id in
var _plot_colours: Array[Color] = []

var _selected_category: String = ""
var _selected_plotids: Array[int] = []


func _process(delta: float) -> void:
	queue_redraw()


func set_metadata(max_x: int, min_y: float, max_y: float) -> void:
	_max_x = max_x
	_min_y = min_y
	_max_y = max_y


func add_plots(category: String, id_plots: Dictionary) -> void:
	_plots[category] = id_plots


func set_colours(colours: Array[Color]) -> void:
	_plot_colours = colours


func set_category(category: String) -> void:
	_selected_category = category


func set_selected_plotids(plotids: Array[int]) -> void:
	_selected_plotids = plotids


# convert a y value to a percentage of the drawable area (oriented downwards
func _y_to_drawable(val: float) -> float:
	var total = _max_y - _min_y
	return 1 - ((val - _min_y) / total)


func _draw() -> void:
	var rect = get_rect()
	var xstep = rect.size.x / _max_x # TODO: get 5 from the stats_screen
	
	# draw the x axis
	var zero_y = _y_to_drawable(0.0)
	draw_line(Vector2(0, zero_y * rect.size.y), Vector2(rect.size.x, zero_y * rect.size.y), DEFAULT_COLOR, 2)
	draw_string(
			_font,
			Vector2(-_string_width - 4, zero_y * rect.size.y),
			"0",
			HORIZONTAL_ALIGNMENT_RIGHT,
			_string_width,
			_font_size,
			DEFAULT_COLOR
	)
	# draw the y axis
	draw_line(Vector2(0, rect.size.y), Vector2(0, 0), DEFAULT_COLOR, 2)
	draw_string(
			_font,
			Vector2(-_string_width - 4, 0.0),
			str(int(_max_y)),
			HORIZONTAL_ALIGNMENT_RIGHT,
			_string_width,
			_font_size,
			DEFAULT_COLOR
	)
	
	var plots = _plots.get(_selected_category, null)
	if plots == null:
		return
	for plotid in plots.keys():
		if plotid in _selected_plotids:
			# draw a single plot
			
			var y_array: Array = plots[plotid]
			var plot_array: Array[Vector2] = []
			
			# the color to work in
			var color = _plot_colours[plotid % plots.size()]
			for i in y_array.size():
				var xx = (i + 1) * xstep
				var yy = (_y_to_drawable(y_array[i])) * rect.size.y
				var p = Vector2(xx, yy)
				plot_array.append(p)
				# draw a point at appropriate height
				draw_circle(p, 8, color)
				# draw the label above
				# TBD
				#draw_string(
						#_font,
						#Vector2(xx - _string_width/2, yy-16),
						#str(y_array[i]),
						#HORIZONTAL_ALIGNMENT_CENTER,
						#_string_width,
						#_font_size,
						#DEFAULT_COLOR
				#)
				
				# draw the marker on the x axis
				draw_line(Vector2(xx, zero_y*rect.size.y-4), Vector2(xx, zero_y*rect.size.y+4), DEFAULT_COLOR)
				draw_string(
						_font,
						Vector2(xx - _string_width/2, rect.size.y+16),
						str(i+1),
						HORIZONTAL_ALIGNMENT_CENTER,
						_string_width,
						_font_size,
						DEFAULT_COLOR
				)
			
			draw_polyline(plot_array, color, 4)

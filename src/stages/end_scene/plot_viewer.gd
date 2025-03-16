extends MarginContainer
class_name PlotViewer


const DEFAULT_COLOR: Color = Color.WHITE

# the percentage of the plot area at which the zero y should be
var _origin_y: float = 0.0

# a dictionary of plots
# each entry is a category of plots, identified by id (also a dictionary)
# each entry of that is an Array of values, corresponding to the y-values to plot
# these y-values are given as percentages, where 1 is the highest value visually possible in the plot
var _plots: Dictionary[String, Dictionary] = {}
# the colour to draw all plots of the selected id in
var _plot_colours: Dictionary[int, Color] = {}

var _selected_category: String = ""
var _selected_plotids: Array[int] = []


func _process(delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	var plots = _plots[_selected_category]
	for plotid in plots.keys():
		if plotid in _selected_plotids:
			# draw a single plot
			
			# the color to work in
			var color = _plot_colours.get(plotid, DEFAULT_COLOR)
			
			

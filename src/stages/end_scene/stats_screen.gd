extends PanelContainer
class_name StatsScreen


const PLAYER_COLOURS: Array[Color] = [
	Color("eb564b"),
	Color("4da6ff"),
	Color("8fde5d"),
	Color("ffe478"),
]

# set via the editor
@export var _category_btngroup: ButtonGroup

@onready var _plot_viewer: PlotViewer = %PlotViewer
@onready var _player_container: VBoxContainer = %PlayerContainer

var _selected_players: Array[int] = []


func _ready():
	_category_btngroup.pressed.connect(_on_ctg_btn_pressed)


## receive the array of round_stats
func setup(rounds_stats: Array[Dictionary]) -> void:
	var min_y := INF
	var max_y := -INF
	var max_x := rounds_stats.size()
	
	var plots: Dictionary[String, Dictionary] = {
		"answered": {},
		"correct": {},
		"coop": {}
	}
	
	_selected_players = []
	
	for roud_data in rounds_stats:
		_selected_players = roud_data.keys()
		for px in roud_data.keys():
			var pstats: PlayerStats = roud_data[px]
			
			var ans := float(pstats.get_answer_count())
			var cor := float(pstats.get_correct_count())
			var cop := float(pstats.get_coop_count())
			# determine the smallest and largest value
			min_y = min(0.0, min_y, ans, cor, cop)
			max_y = max(max_y, ans, cor, cop)
			
			var ans_plot: Array[float] = plots["answered"].get_or_add(px, [] as Array[float])
			ans_plot.append(ans)
			var cor_plot: Array[float] = plots["correct"].get_or_add(px, [] as Array[float])
			cor_plot.append(cor)
			var cop_plot: Array[float] = plots["coop"].get_or_add(px, [] as Array[float])
			cop_plot.append(cop)
	
	for px in _selected_players:
		var pl_btn = Button.new()
		pl_btn.theme_type_variation = "PlayerCheckButton"
		pl_btn.modulate = PLAYER_COLOURS[px % PLAYER_COLOURS.size()]
		pl_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		pl_btn.text = "Player" + str(px + 1)
		pl_btn.toggle_mode = true
		pl_btn.set_pressed_no_signal(true)
		pl_btn.toggled.connect(_on_player_btn_pressed.bind(px))
		_player_container.add_child.call_deferred(pl_btn)
	
	_plot_viewer.set_metadata(max_x, min_y, max_y)
	for ctg in plots.keys():
		_plot_viewer.add_plots(ctg, plots[ctg])
	_plot_viewer.set_colours(PLAYER_COLOURS) # TODO: set colours from palette
	_plot_viewer.set_category("answered")
	_plot_viewer.set_selected_plotids(_selected_players)


func _on_ctg_btn_pressed(btn) -> void:
	match btn.name:
		"BtnAnswered":
			_plot_viewer.set_category("answered")
		"BtnCorrect":
			_plot_viewer.set_category("correct")
		"BtnCoop":
			_plot_viewer.set_category("coop")


func _on_player_btn_pressed(toggled_on: bool, px: int) -> void:
	# by default erase all instances of it
	while _selected_players.has(px):
		_selected_players.erase(px)
	
	if toggled_on:
		_selected_players.append(px)
	_plot_viewer.set_selected_plotids(_selected_players)

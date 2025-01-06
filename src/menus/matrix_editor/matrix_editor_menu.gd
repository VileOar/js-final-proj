## menu to edit the payoff matrix
##
## should allow to edit or reset each individual matrix value
extends Control
class_name MatrixEditorMenu

## array of the outcome uis
@onready var _outcome_widgets = [ # must do this manually because of the order details
	%CC,
	%CD,
	%DC,
	%DD,
]


func _ready():
	_reset_matrix()


func _reset_matrix() -> void:
	var matrix = SharedData.get_payoff_matrix() as PayoffMatrix
	matrix.reset()
	
	# they are ordered just like the matrix
	for outcome_id in _outcome_widgets.size():
		_outcome_widgets[outcome_id].set_outcome_id(outcome_id)
		var outcome_values = matrix.get_matrix_outcome(outcome_id)
		_outcome_widgets[outcome_id].set_outcomes(outcome_values[0], outcome_values[1])


func _on_button_pressed():
	_reset_matrix()

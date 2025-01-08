## menu to edit the payoff matrix
##
## should allow to edit or reset each individual matrix value
extends Control
class_name MatrixEditorMenu

# ref to the editor window
@onready var _editor_display: VBoxContainer = %EditorDisplay
# ref to the context window
@onready var _context_display: MarginContainer = %ContextDisplay

# array of the outcome uis
@onready var _outcome_widgets = [ # must do this manually because of the order details
	%CC,
	%DC,
	%CD,
	%DD,
]

@onready var _p1_info_choice: Label = %P1InfoChoice
@onready var _p2_info_choice: Label = %P2InfoChoice

@onready var _p1_info_result: Label = %P1InfoResult
@onready var _p2_info_result: Label = %P2InfoResult

@onready var _apply_btn: Button = %ApplyBtn

# ref to the currently focused widget
var _focused_widget: PayoffOutcomeWidget

# ref to the matrix data
var _matrix_data: PayoffMatrix


func _ready():
	_matrix_data = SharedData.get_payoff_matrix() as PayoffMatrix
	_set_matrix_ui()


# set the UI elements to match the matrix data
func _set_matrix_ui() -> void:
	# they are ordered just like the matrix
	for widget in _outcome_widgets:
		var outcome_mask = widget.get_outcome_mask()
		var outcome_values = _matrix_data.get_matrix_outcome(outcome_mask)
		widget.set_outcomes(outcome_values[0], outcome_values[1])
	
	_apply_btn.disabled = true


# update the info text
func _update_info_text() -> void:
	if _focused_widget != null:
		var outcome_mask = _focused_widget.get_outcome_mask()
		_p1_info_choice.text = "defects" if outcome_mask & 1 else "cooperates"
		_p2_info_choice.text = "defects" if outcome_mask & 2 else "cooperates"
		
		var outcome_values = _focused_widget.get_current_values()
		_p1_info_result.text = str(outcome_values[0])
		_p2_info_result.text = str(outcome_values[1])
	else:
		push_warning("Tried to update info but focused widget is null. Aborting.")


# callback to when one of the widgets is updated
func _on_payoff_widget_update(outcome_mask: int, _p1_value: int, _p2_value: int) -> void:
	_focused_widget = _outcome_widgets[outcome_mask]
	_update_info_text()
	_apply_btn.disabled = false


# callback when a widget is hovered into
func _on_widget_mouse_entered(outcome_mask: int) -> void:
	_focused_widget = _outcome_widgets[outcome_mask]
	_update_info_text()


# callback to the reset matrix button
func _on_reset_btn_pressed() -> void:
	_matrix_data.reset()
	_set_matrix_ui()


func _on_apply_btn_pressed() -> void:
	for widget in _outcome_widgets:
		var outcomes = widget.get_current_values()
		_matrix_data.set_matrix_outcome(widget.get_outcome_mask(), outcomes[0], outcomes[1])
	_apply_btn.disabled = true


func _on_context_btn_pressed() -> void:
	_editor_display.hide()
	_context_display.show()


func _on_hide_context_btn_pressed() -> void:
	_editor_display.show()
	_context_display.hide()

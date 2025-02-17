class_name PayoffOutcomeWidget
extends MarginContainer
## Widget node to handle editing the values of a matrix outcome.
##
## Responds to editing either of the two line edits and sends it to SharedData.
## NOTE: This node assumes 2 players per dyad.

## sent when the values are updated
signal values_updated(outcome_mask, p1_value, p2_value)
## sent when hovered into, custom to also send identifier
signal hovered_into(outcome_mask)

# whether, in this payoff, p1 defects
@export var _p1_defect: bool
# whether, in this payoff, p2 defects
@export var _p2_defect: bool

## ref to the player 1 outcome
@onready var _p1_outcome = %P1
@onready var _p2_outcome = %P2

# this outcomes identifier as defined in Global Outcomes enum
var _outcome_mask: int


func _ready() -> void:
	_outcome_mask = 1 if _p1_defect else 0 # concat the first bit
	_outcome_mask |= 2 if _p2_defect else 0 # concat the second bit


## getter for the outcome mask
func get_outcome_mask() -> int:
	return _outcome_mask


## getter for the current values
func get_current_values() -> Array:
	return [int(_p1_outcome.value), int(_p2_outcome.value)]


# DYAD
## manually set the outcomes
func set_outcomes(outcomes: Array[int]) -> void:
	if outcomes.size() == 2:
		_p1_outcome.set_value_no_signal(outcomes[0])
		_p2_outcome.set_value_no_signal(outcomes[1])
	else:
		push_error("Expected two players. Aborted.")


func _on_value_changed(_value):
	values_updated.emit(_outcome_mask, int(_p1_outcome.value), int(_p2_outcome.value))


func _on_mouse_entered() -> void:
	hovered_into.emit(_outcome_mask)

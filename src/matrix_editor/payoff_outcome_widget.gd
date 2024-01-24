## widget node to handle editing the values of a matrix outcome
##
## responds to editing either of the two line edits and sends it to SharedData
extends MarginContainer
class_name PayoffOutcomeWidget

## ref to the player 1 outcome
@onready var _p1_outcome = %P1
@onready var _p2_outcome = %P2

## this outcomes identifier as defined in Global Outcomes enum
var _outcome_id : int


## set the outcome id
func set_outcome_id(outcome : int) -> void:
	_outcome_id = outcome


## manually set the outcomes
func set_outcomes(outcome1 : int, outcome2 : int) -> void:
	_p1_outcome.set_value_no_signal(outcome1)
	_p2_outcome.set_value_no_signal(outcome2)


## parse the values in the labels and set to matrix
func set_matrix_outcome_from_input() -> void:
	var matrix = SharedData.get_payoff_matrix() as PayoffMatrix
	matrix.set_matrix_outcome(_outcome_id, int(_p1_outcome.value), int(_p2_outcome.value))


# not even gonna try making this pretty or called on the main controller
# the matrix is edited right here on the callback, screw it

func _on_value_changed(value):
	set_matrix_outcome_from_input()

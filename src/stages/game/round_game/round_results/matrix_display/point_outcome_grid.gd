## panel to display the payoff matrix during the end of the round
##
## sould animate the outcome for each point
extends MarginContainer
class_name PointOutcomeGrid

## the various outcome panels
@onready var _outcomes = [
	%OutcomeCC,
	%OutcomeCD,
	%OutcomeDC,
	%OutcomeDD,
]


## set the payoffs
func set_payoffs(matrix: PayoffMatrix) -> void:
	for outcome_id in _outcomes.size():
		var outcome_values = matrix.get_matrix_outcome(outcome_id)
		_outcomes[outcome_id].set_payoff(outcome_values[0], outcome_values[1])


## trigger the correct animation
func trigger_outcome_anim(outcome: int, anim_speed: float) -> void:
	if outcome >= 0 and outcome < _outcomes.size():
		_outcomes[outcome].trigger_animation(outcome, anim_speed)

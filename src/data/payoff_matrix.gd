## the class defining the payoff matrix
##
## used as a class to keep it organised
extends Resource
class_name PayoffMatrix

var _outcomes = []

## set the matrix to its default value
func reset() -> void:
	_outcomes = [
		[10,10],
		[0,15],
		[15,0],
		[2,2]
	]


## set one of the outcomes
func set_matrix_outcome(outcome_mask : int, p1_payoff : int, p2_payoff : int) -> bool:
	if outcome_mask in Global.Outcomes.values():
		_outcomes[outcome_mask] = [p1_payoff, p2_payoff]
		return true
	push_error("Tried to set an invalid matrix outcome")
	return false


## get one of the outcomes
func get_matrix_outcome(outcome_mask : int) -> Array:
	if outcome_mask in Global.Outcomes.values():
		return _outcomes[outcome_mask]
	push_error("Tried to get an invalid matrix outcome")
	return []

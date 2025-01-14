## the class defining the payoff matrix
##
## used as a class to keep it organised
extends Resource
class_name PayoffMatrix

var _outcomes = []


func _init():
	reset()


## set the matrix to its default value
func reset() -> void:
	_outcomes = [
		[2,2],
		[-2,4],
		[4,-2],
		[0,0]
	]


## return a copy of this data
func copy() -> PayoffMatrix:
	var dup := PayoffMatrix.new()
	dup._outcomes = _outcomes.duplicate(true)
	return dup


## set one of the outcomes
func set_matrix_outcome(outcome_mask: int, p1_payoff: int, p2_payoff: int) -> bool:
	if outcome_mask in Global.Outcomes.values():
		_outcomes[outcome_mask] = [p1_payoff, p2_payoff]
		return true
	assert(false, "Tried to set an invalid matrix outcome")
	return false


## get one of the outcomes
func get_matrix_outcome(outcome_mask: int) -> Array:
	if outcome_mask in Global.Outcomes.values():
		return _outcomes[outcome_mask]
	assert(false, "Tried to get an invalid matrix outcome")
	return []

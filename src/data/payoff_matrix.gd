## the class defining the payoff matrix
##
## used as a class to keep it organised
extends Resource
class_name PayoffMatrix

var _outcomes: Array[Array] = []


func _init():
	reset()


## set the matrix to its default value
func reset() -> void:
	_outcomes = [
		[2,2],
		[6,-2],
		[-2,6],
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
func get_matrix_outcome(outcome_mask: int) -> Array[int]:
	if outcome_mask in Global.Outcomes.values():
		var ret: Array[int] = []
		ret.assign(_outcomes[outcome_mask])
		return ret
	assert(false, "Tried to get an invalid matrix outcome")
	return []

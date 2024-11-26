## this scene controls the display of the score of the dyad
##
## should respond to adding a point and start its own animation/sequence to add it visually
extends MarginContainer
class_name DyadScoreUI

## ref to the label
@onready var _score_label = %Score

## internal counter of how many points there are
var _score := 0


## this function reports a new point added
func add_points(points : int = 1) -> void:
	_score += points
	_score_label.text = str(_score)


## manually set points
func set_points(points : int) -> void:
	_score = points
	_score_label.text = str(_score)


## return points to default value
func reset_points() -> void:
	_score = 0
	_score_label.text = str(_score)

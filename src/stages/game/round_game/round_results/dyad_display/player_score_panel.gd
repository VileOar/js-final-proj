## panel to be reused in other contexts that identifies player and score
##
## this panel should display info to identify the player, their icon, skin, ... and display a score, 
## either total or round score
extends MarginContainer
class_name PlayerScorePanel

# the score label
@onready var _score = %PlayerScore
# ref to the node where score numbers should spawn
@onready var _number_pivot: Node2D = %ScoreNumberPivot

## keep the score as an int
var _score_value := 0


## set the score and populate UI
func set_score(score: int) -> void:
	_score_value = score
	_update_score_ui()


## add to score
func add_score(add: int) -> void:
	_score_value += add
	_update_score_ui()


## multiply to score
func mul_score(mul: float) -> void:
	_score_value = (float(_score_value) * mul)
	_update_score_ui()


## spawn a number with the added points[br]
## target_node specifies where to add the new number
func score_effect(score_number_scene: PackedScene, added_score: int) -> void:
	# spawn score indicator
	var score = _spawn_number(score_number_scene)
	score.start_anim(added_score, ScoreNumber.Mode.NORMAL)


func penalty_effect(score_number_scene: PackedScene, penalty_multiplier: float) -> void:
	# display penalty
	var score = _spawn_number(score_number_scene)
	score.start_anim(-100*(1-penalty_multiplier), ScoreNumber.Mode.PENALTY)


func _spawn_number(score_number_scene: PackedScene) -> ScoreNumber:
	var score = score_number_scene.instantiate() as ScoreNumber
	_number_pivot.add_child(score)
	
	return score


## update the ui of scores
func _update_score_ui() -> void:
	_score.text = str(_score_value)

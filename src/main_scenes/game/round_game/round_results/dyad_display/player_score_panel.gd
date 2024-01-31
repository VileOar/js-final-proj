## panel to be reused in other contexts that identifies player and score
##
## this panel should display info to identify the player, their icon, skin, ... and display a score, 
## either total or round score
extends MarginContainer
class_name PlayerScorePanel

## the player label
@onready var _label = %PlayerLabel
## their score label
@onready var _score = %PlayerScore

## keep the score as an int
var _score_value := 0


## set the player id and populate the rest of the UI from it
func set_player(player_id : int) -> void:
	_label.text = "Player %s" % [player_id + 1]


## set the score and populate UI
func set_score(score : int) -> void:
	_score_value = score
	_update_score_ui()


## add to score
func add_score(add : int) -> void:
	_score_value += add
	_update_score_ui()


## spawn a number with the added points[br]
## target_node specifies where to add the new number
func spawn_number(target_node : Node, score_number_scene : PackedScene, added_score : int) -> void:
	# spawn score indicator
	var score = score_number_scene.instantiate() as ScoreNumber
	var pos = get_global_rect().get_center()
	pos.y = get_global_rect().position.y - 128
	score.start(pos, added_score)
	target_node.add_child(score)


func apply_penalty(target_node : Node, score_number_scene : PackedScene) -> void:
	# apply penalty
	_score_value = int(float(_score_value) * Global.LOSE_PENALTY_MULTIPLIER)
	# display penalty
	var score = score_number_scene.instantiate() as ScoreNumber
	var pos = get_global_rect().get_center()
	pos.y = get_global_rect().position.y - 128
	score.start_penalty(pos, Global.LOSE_PENALTY_MULTIPLIER)
	target_node.add_child(score)
	
	_update_score_ui()


## update the ui of scores
func _update_score_ui() -> void:
	_score.text = str(_score_value)

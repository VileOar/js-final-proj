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


## set the player id and populate the rest of the UI from it
func set_player(player_id : int) -> void:
	# TODO: populate rest of UI
	_label.text = "Player %s" % [player_id + 1]


## set the score and populate UI
func set_score(score : int) -> void:
	_score.text = str(score)

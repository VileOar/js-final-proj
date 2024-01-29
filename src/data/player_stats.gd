## data structure to manage statistics of a player
##
## keeps track of some data of players and calculates other; should be able to keep track of[br]
## -number of answers[br]
## -answers correct (and then percentage)[br]
## -answers cooperated (and percentage)[br]
extends RefCounted
class_name PlayerStats

## individual score
var _score = 0

## number of answers
var _answer_count = 0
## number of correct answers
var _correct_count = 0
## number of cooperations
var _coop_count = 0


## reset values
func reset() -> void:
	_score = 0
	_answer_count = 0
	_correct_count = 0
	_coop_count = 0


## parse an answer and add its stats[br]
## NOTE: this makes no distinction between player indices, as this class is indifferent to that
func parse_answer(answer : PlayerAnswer):
	_answer_count += 1
	if answer.is_correct():
		_correct_count += 1
	if answer.cooperated():
		_coop_count += 1


# -------------------------------
# || --- SETTERS & GETTERS --- ||
# -------------------------------

func set_score(score : int) -> void:
	_score = _score


func get_score() -> int:
	return _score


func add_score(add : int) -> void:
	_score += add


func get_answer_count() -> int:
	return _answer_count


func get_correct_count() -> int:
	return _correct_count


func get_correct_ratio() -> float:
	return float(_correct_count) / float(_answer_count)


func get_coop_count() -> int:
	return _coop_count


func get_coop_ratio() -> float:
	return float(_coop_count) / float(_answer_count)

## data structure to manage statistics of a player
##
## keeps track of some data of players and calculates other; should be able to keep track of[br]
## -number of answers[br]
## -answers correct (and then percentage)[br]
## -answers cooperated (and percentage)[br]
extends RefCounted
class_name PlayerStats

## individual score
var _score: int = 0

## number of answers
var _answer_count: int = 0
## number of correct answers
var _correct_count: int  = 0
## number of cooperations
var _coop_count: int = 0


## reset values
func reset(score: int = 0, answer_count: int = 0, correct_count: int = 0, coop_count: int = 0) -> void:
	_score = score
	_answer_count = answer_count
	_correct_count = correct_count
	_coop_count = coop_count


## parse an answer and add its stats[br]
## NOTE: this makes no distinction between player indices, as this class is indifferent to that
func parse_answer(answer: PlayerAnswer):
	_answer_count += 1
	if answer.is_correct():
		_correct_count += 1
	if answer.cooperated():
		_coop_count += 1


## return a copy of this object
func duplicate() -> PlayerStats:
	var dup = PlayerStats.new()
	dup.reset(_score, _answer_count, _correct_count, _coop_count)
	return dup


# -------------------------------
# || --- SETTERS & GETTERS --- ||
# -------------------------------

func set_score(score: int) -> void:
	_score = score


func get_score() -> int:
	return _score


func add_score(add: int) -> void:
	_score += add


func mult_score(mult: float) -> void:
	_score = int(roundi(float(_score) * mult))


func get_answer_count() -> int:
	return _answer_count


func get_correct_count() -> int:
	return _correct_count


func get_correct_ratio() -> float:
	return 100 * float(_correct_count) / float(_answer_count) if _answer_count > 0 else 0.0


func get_coop_count() -> int:
	return _coop_count


func get_coop_ratio() -> float:
	return 100 * float(_coop_count) / float(_answer_count) if _answer_count > 0 else 0.0

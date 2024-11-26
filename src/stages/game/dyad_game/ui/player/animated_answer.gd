## animate player answers
extends Node2D
class_name AnimatedAnswer


## display an answer according to a player answer
func animate_answer(answer : PlayerAnswer) -> void:
	show()
	
	var anim = "none"
	
	# default cancel all 4
	$Left.play(anim)
	$Right.play(anim)
	$Up.play(anim)
	$Down.play(anim)
	
	# decide animation
	if !Utils.nullcheck(answer): # if no answer is given, display nothing
		return
	else:
		force_animation(answer.direction(), answer.is_correct(), answer.cooperated())


## manually animate a direction
func force_animation(direction: int, correct: bool, coop: bool) -> void:
	var anim = "none"
	
	# default cancel all 4
	$Left.play(anim)
	$Right.play(anim)
	$Up.play(anim)
	$Down.play(anim)
	
	# decide animation
	if correct:
		anim = "correct"
	else:
		anim = "wrong" if coop else "defect"
	
	# play the correct direction
	match direction:
		Global.Directions.LEFT:
			$Left.play(anim)
		Global.Directions.RIGHT:
			$Right.play(anim)
		Global.Directions.UP:
			$Up.play(anim)
		Global.Directions.DOWN:
			$Down.play(anim)


## hide the answer
func hide_answer() -> void:
	hide()

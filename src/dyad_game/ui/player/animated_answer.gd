## animate player answers
extends Node2D
class_name AnimatedAnswer


## display an answer according to a player answer
func animate_answer(answer : PlayerAnswer) -> void:
	show()
	
	var anim = "none"
	
	# default cancel all 4
	# TODO:
	#$Left.play(anim)
	#$Right.play(anim)
	#$Up.play(anim)
	#$Down.play(anim)
	
	# decide animation
	if answer.is_correct():
		anim = "correct"
	else:
		anim = "wrong" if answer.cooperated() else "defect"
	
	# play the correct direction
	# TODO:
	#match answer.direction():
		#Global.Directions.LEFT:
			#$Left.play(anim)
		#Global.Directions.RIGHT:
			#$Right.play(anim)
		#Global.Directions.UP:
			#$Up.play(anim)
		#Global.Directions.DOWN:
			#$Down.play(anim)


## hide the answer
func hide_answer() -> void:
	hide()

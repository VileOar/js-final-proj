## to be used by a PointOutcomeGrid
##
## contains different animation according to outcome
extends Control
class_name OutcomePanel


## set the payoff label
func set_payoff(p1_payoff : int, p2_payoff : int) -> void:
	%Label0.text = "%s" % [p1_payoff]
	%Label1.text = "%s" % [p2_payoff]


## trigger an animation according to an outcome identifier as defined in global Outcome enum
func trigger_animation(payoff_outcome : int, speed : float = 1.0):
	var anim = %AnimationPlayer as AnimationPlayer
	match payoff_outcome:
		Global.Outcomes.CC:
			anim.play("coop", -1, speed)
		Global.Outcomes.DC, Global.Outcomes.CD:
			anim.play("defect", -1, speed)
		Global.Outcomes.DD:
			anim.play("mutual", -1, speed)
		_:
			assert(false, "invalid outcome given")

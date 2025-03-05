## a number that rises in the air and fades out
extends Node2D
class_name ScoreNumber

## the mode of animation
enum Mode {
	NORMAL,
	PENALTY,
}

var _speed = 320 # px/sec

var _penalty = false


func _physics_process(delta: float) -> void:
	if _speed < (10 if _penalty else 100):
		modulate.a -= 0.02
		if modulate.a <= 0:
			queue_free()
	if _speed > 5:
		_speed *= 0.9
	
	position.y -= _speed * delta


func start_anim(value: float, mode: Mode) -> void:
	$Label.text = str(int(value))
	if value >= 0.0:
		$Label.text = "+" + $Label.text # if non-negative, add a plus sign
	
	match mode:
		Mode.NORMAL:
			pass
		Mode.PENALTY:
			$Label.text += "%"
			($Label as Label).theme_type_variation = "PenaltyLabel"
			_speed = 180
			_penalty = true

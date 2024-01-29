## a number that rises in the air and fades out
extends Node2D
class_name ScoreNumber

var speed = 320 # px/sec


func _physics_process(delta: float) -> void:
	if speed < 100:
		modulate.a -= 0.02
		if modulate.a <= 0:
			queue_free()
	if speed > 5:
		speed *= 0.9
	
	position.y -= speed * delta


func start(pos : Vector2, value : int) -> void:
	global_position = pos
	if value >= 0:
		$Label.text = "+%s" % [value]
	else:
		$Label.text = str(value)

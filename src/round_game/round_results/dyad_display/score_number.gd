## a number that rises in the air and fades out
extends Node2D
class_name ScoreNumber

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


func start(pos : Vector2, value : int) -> void:
	global_position = pos
	if value >= 0:
		$Label.text = "+%s" % [value]
	else:
		$Label.text = str(value)


func start_penalty(pos : Vector2, penalty : float) -> void:
	global_position = pos
	$Label.text = "-%s%%" % [100*(1-penalty)]
	$Label.add_theme_color_override("font_color", Color("ff6b97"))
	($Label as Label).add_theme_font_size_override("font_size", 24)
	_speed = 180
	_penalty = true

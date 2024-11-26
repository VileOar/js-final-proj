## a visual representation of points in a stack
##
## this stack must be able to add/remove points as required[br]
## all management for how this is displayed happens inside this script[br]
## internally, this script manages a hbox of vboxes, corresponding to the stacks
extends MarginContainer
class_name PointStack

## height of the stack
const HEIGHT = 5

## the texture to use, the resource should be the same ref for everything
@export var _point_texture : Texture

## ref to the columns
@onready var _columns: HBoxContainer = $Columns

## the vbox currently at the tail
var _tail_vbox : VBoxContainer


## add a new point to the stack
func push_point() -> void:
	if _columns.get_child_count() == 0 or _tail_vbox.get_child_count() == HEIGHT:
		_add_new_stack()
	
	var point_icon = TextureRect.new()
	point_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
	point_icon.texture = _point_texture
	_tail_vbox.add_child(point_icon)


## remove a point from the stack
func pop_point() -> void:
	if _columns.get_child_count() == 0:
		if Utils.nullcheck(_tail_vbox):
			push_error("Tail VBox pointer was not null, even though, columns were empty. Freeing just in case")
			_tail_vbox.queue_free()
			_tail_vbox = null
		return
	
	var to_delete = _tail_vbox.get_child(-1)
	_tail_vbox.remove_child(to_delete)
	to_delete.queue_free()
	if _tail_vbox.get_child_count() == 0:
		_columns.remove_child(_tail_vbox)
		_tail_vbox.queue_free()
		_tail_vbox = _columns.get_child(-1) if _columns.get_child_count() > 0 else null


## delete all points
func clear_points() -> void:
	while _columns.get_child_count() > 0:
		var col = _columns.get_child(-1)
		_columns.remove_child(col)
		col.queue_free()


## manually set amount of points
func set_points(points : int) -> void:
	clear_points()
	
	for i in points:
		push_point()


## add a new stack of points (a vbox)
func _add_new_stack() -> void:
	_tail_vbox = VBoxContainer.new()
	_tail_vbox.alignment = BoxContainer.ALIGNMENT_END
	_tail_vbox.add_theme_constant_override("separation", 0)
	
	_columns.add_child(_tail_vbox)

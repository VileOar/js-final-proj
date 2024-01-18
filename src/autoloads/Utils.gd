## this autoload contains useful operations common between multiple nodes
##
## these could include specific mathematical calculations (like calculations on the map grid)
extends Node


## dictionary of physics layers with a set name
var _named_layers : Dictionary


func _ready():
	for i in range(1, 33):
		var layer_name = ProjectSettings.get_setting("layer_names/2d_physics/layer_" + str(i), "")
		if layer_name != "":
			_named_layers[layer_name] = 1 << (i - 1) # set the value the corresponding layer value


## get a collision bitmask by passing an array of registered layer names
func get_collision_bitmask(layer_names : Array) -> int:
	var mask = 0
	
	for layer in layer_names:
		if _named_layers.has(layer):
			mask |= _named_layers[layer]
	
	return mask

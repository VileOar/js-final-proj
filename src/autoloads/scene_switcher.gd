extends Node
## A custom top scene switcher and manager.
##
## Handles switching of the main scene, so that other nodes never have to use packed scenes or any
## of the SceneTree methods directly.[br]
## Additionally, it can also be used for handling things like loading screens.[br]
## The reason it is a scene, instead of a script is that it makes it easier to add PackedScenes via
## the inspector, which also means they autoupdate their paths if moved.
##
## @tutorial(Based on): https://docs.godotengine.org/en/stable/tutorials/scripting/singletons_autoload.html#custom-scene-switcher
# v1.0 (2025-01-03)

# Enum of mode of identifying scenes.
enum _SceneMode {
	PATH,
	SCENEID,
}

## A dictionary holding PackedScene resources, identifies by key.
@export var scene_dictionary: Dictionary = {}

# The currently loaded top scene
var _current_scene = null


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_current_scene = _get_current_scene()


# -----------------------
# || --- ENDPOINTS --- ||
# -----------------------

## Intermediary between this autoload and the remaining scenes in the game.[br]
## Identify new scene via path.
func switch_topscene_path(path: String) -> void:
	_validate_current_scene()
	# This function will usually be called from a signal callback,
	# or some other function in the current scene.
	# Deleting the current scene at this point is
	# a bad idea, because it may still be executing code.
	# This will result in a crash or unexpected behavior.
	
	# The solution is to defer the load to a later time, when
	# we can be sure that no code from the current scene is running:
	
	_deferred_goto_scene.call_deferred(path, _SceneMode.SCENEID)


## Intermediary between this autoload and the remaining scenes in the game.[br]
## Identify new scene via custom id.
func switch_topscene_id(sceneid: String) -> void:
	_validate_current_scene()
	# This function will usually be called from a signal callback,
	# or some other function in the current scene.
	# Deleting the current scene at this point is
	# a bad idea, because it may still be executing code.
	# This will result in a crash or unexpected behavior.
	
	# The solution is to defer the load to a later time, when
	# we can be sure that no code from the current scene is running:
	
	_deferred_goto_scene.call_deferred(sceneid, _SceneMode.SCENEID)


## Simple scene switching using the SceneTree API.
## Identify new scene via path.
func change_topscene_path(path: String) -> void:
	_validate_current_scene()
	get_tree().change_scene_to_file(path)
	_current_scene = _get_current_scene()


## Simple scene switching using the SceneTree API.
## Identify new scene via custom id.
func change_topscene_id(sceneid: String) -> void:
	_validate_current_scene()
	get_tree().change_scene_to_packed(_get_packed_scene(sceneid))
	_current_scene = _get_current_scene()


# ---------------------
# || --- PRIVATE --- ||
# ---------------------

# The safe function where switching scenes actually happens, so should be hidden from outside.
func _deferred_goto_scene(string_key: String, mode: _SceneMode) -> void:
	# It is now safe to remove the current scene.
	_current_scene.free()
	
	var new_scene: Resource = null
	
	match mode:
		_SceneMode.PATH:
			new_scene = ResourceLoader.load(string_key)
		_SceneMode.SCENEID:
			new_scene = _get_packed_scene(string_key)
	
	# Instance the new scene.
	_current_scene = new_scene.instantiate()
	
	# Add it to the active scene, as child of root.
	get_tree().root.add_child(_current_scene)

	# Optionally, to make it compatible with the SceneTree API.
	get_tree().current_scene = _current_scene


# Get a PackedScene resource from the dictionary
func _get_packed_scene(sceneid: String) -> PackedScene:
	var scene = scene_dictionary.get(sceneid)
	if scene == null:
		push_error("CRITICAL: Invalid scene id passed: %s. Shutting Down" % sceneid)
		get_tree().quit(1)
	
	return scene


# Get the current scene in the tree
func _get_current_scene() -> Node:
	var root = get_tree().root
	# Using a negative index counts from the end, so this gets the last child node of `root`.
	return root.get_child(-1)


# Check if the stored current scene corresponds to the actual current scene.[br]
# If it doesn't, update stored current scene and throw warning
func _validate_current_scene() -> bool:
	var actual_scene = _get_current_scene()
	if _current_scene != actual_scene:
		_current_scene = actual_scene
		push_warning("""
				Stored current scene does not match actual top scene.
				This is likely caused by switching scenes via SceneTree, instead of the Autoload.
				Rectifying value.
		""")
		return false
	
	return true

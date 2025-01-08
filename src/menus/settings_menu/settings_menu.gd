class_name SettingsMenu
extends Control
## Screen for editing game settings

@onready var _duration_input: SpinBox = %DurationInput
@onready var _rounds_input: SpinBox = %RoundsInput
@onready var _penalty_input: SpinBox = %PenaltyInput

@onready var _all_descriptions: MarginContainer = %AllDescriptions
@onready var _duration_desc: Label = %DurationInputDesc
@onready var _rounds_desc: Label = %RoundsInputDesc
@onready var _penalty_desc: Label = %PenaltyInputDesc
@onready var _instructions_input_desc: Label = %InstructionsInputDesc

@warning_ignore("unused_private_class_variable")
@onready var _default_btn: Button = %DefaultBtn
@onready var _apply_btn: Button = %ApplyBtn


func _ready() -> void:
	setup()


## setup the settings to their currently saved values
func setup() -> void:
	_duration_input.get_line_edit().text = str(SharedData.get_settings().round_time)
	_duration_input.apply()
	_rounds_input.get_line_edit().text = str(SharedData.get_settings().num_rounds)
	_rounds_input.apply()
	_penalty_input.get_line_edit().text = str(SharedData.get_settings().lose_penalty_multiplier * 100)
	_penalty_input.apply()
	
	_apply_btn.disabled = true


# helper function to hide all descriptions
func _hide_all_descriptions() -> void:
	for child in _all_descriptions.get_children():
		child.hide()


# called when any of the settings is changed, just to enable the apply button
func _on_setting_changed(_value) -> void:
	_apply_btn.disabled = false


# restore ui values to the default
func _on_default_btn_pressed() -> void:
	SharedData.get_settings().reset()
	setup()


# apply the values in the ui
func _on_apply_btn_pressed() -> void:
	SharedData.get_settings().round_time = float(_duration_input.get_line_edit().text)
	SharedData.get_settings().num_rounds = int(_rounds_input.get_line_edit().text)
	SharedData.get_settings().round_time = float(_duration_input.get_line_edit().text) / 100.0
	_apply_btn.disabled = true


# change setting
func _on_instructions_input_toggled(toggled_on: bool) -> void:
	SharedData.set_instructions_settings(toggled_on)


# change the description based on what setting was hovered
func _on_duration_input_mouse_entered() -> void:
	_hide_all_descriptions()
	_duration_desc.show()


# change the description based on what setting was hovered
func _on_rounds_input_mouse_entered() -> void:
	_hide_all_descriptions()
	_rounds_desc.show()


# change the description based on what setting was hovered
func _on_penalty_input_mouse_entered() -> void:
	_hide_all_descriptions()
	_penalty_desc.show()


func _on_instructions_input_mouse_entered() -> void:
	_hide_all_descriptions()
	_instructions_input_desc.show()

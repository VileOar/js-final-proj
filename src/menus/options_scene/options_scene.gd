class_name OptionsScene
extends Control
## Topscene for the Options menu.
##
## This menu works as a tab container, in which each tab is a separate scene.[br]
## These are:[br]
## - Settings[br]
## - Matrix Editor[br]
## - Instructions[br]
## - Credits

# ref to settings tab button
@onready var _settings_btn: Button = %SettingsBtn
# ref to matrix tab button
@onready var _matrix_btn: Button = %MatrixBtn
# ref to instructions tab button
@onready var _instructions_btn: Button = %InstructionsBtn
# ref to credits tab button
@onready var _credits_btn: Button = %CreditsBtn
# button group for the tab buttons
var _tab_buttons: ButtonGroup

# the container holding all tabs
@onready var _tab_display_container: MarginContainer = %TabDisplayContainer
# settings scene ref
@onready var _settings_scene: SettingsMenu = %SettingsScene
# matrix scene ref
@onready var _matrix_scene: MatrixEditorMenu = %MatrixScene
# instructions scene ref
@onready var _instructions_scene: Control = %InstructionsScene
# credits scene ref
@onready var _credits_scene: Control = %CreditsScene


func _ready() -> void:
	# setup tab buttons and group
	_tab_buttons = ButtonGroup.new()
	_settings_btn.button_group = _tab_buttons
	_matrix_btn.button_group = _tab_buttons
	_instructions_btn.button_group = _tab_buttons
	_credits_btn.button_group = _tab_buttons
	_settings_btn.set_pressed_no_signal(true)
	_tab_buttons.pressed.connect(_on_tab_changed)


# ------------------------------
# || --- SIGNAL CALLBACKS --- ||
# ------------------------------

# callback to the tab buttons
func _on_tab_changed(btn: BaseButton) -> void:
	for child in _tab_display_container.get_children():
		child.hide()
	match btn:
		_settings_btn:
			_settings_scene.show()
		_matrix_btn:
			_matrix_scene.show()
		_instructions_btn:
			_instructions_scene.show()
		_credits_btn:
			_credits_scene.show()


func _on_back_btn_pressed() -> void:
	SceneSwitcher.switch_topscene_id("title_screen")

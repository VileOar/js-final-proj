class_name AnimateStatsState
extends StackState


# how many animations are finished
var _anim_finish_counter = 0

# whether listening for skip
var _listen_skip = true


func _ready() -> void:
	Signals.general_input.connect(_on_general_input)


func _on_general_input(_event):
	if is_active() and _listen_skip:
		_listen_skip = false
		for dyad in fsm().dyad_panels:
			dyad.skip_stats_animation()
		end_animation()


func activate():
	_listen_skip = true
	_anim_finish_counter = 0
	for dyad in fsm().dyad_panels:
		dyad = dyad as DyadResultsPanel
		dyad.animate_stats()


func end_animation():
	_listen_skip = false
	for dyad in fsm().dyad_panels:
		dyad = dyad as DyadResultsPanel
		dyad.solve_penalty_if_loss(fsm().penalty_multiplier)
	replace_state("FinishedResultsState")


func on_anim_finished():
	_anim_finish_counter += 1
	if _anim_finish_counter >= fsm().dyad_panels.size():
		
		await get_tree().create_timer(0.4).timeout
		
		if is_active():
			end_animation()

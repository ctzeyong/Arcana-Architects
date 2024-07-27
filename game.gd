extends Node2D

var pearls_collected = 0
var final_artefact_collected = false

func _run_once():
	set_patrol_state()
	%LevelPassed.visible = false
	%LevelFailed.visible = false
	Global.gloves_equipped = false

func set_patrol_state():
	%Guard.set_rotate_patrol(80)
	%Guard4.set_rotate_patrol(60)

func _on_purple_portal_level_passed():
	if final_artefact_collected:
		%LevelPassed.visible = true
		get_tree().paused = true


func _on_purple_pearl_pearl_picked_up():
	pearls_collected += 1
	print("pearl")


func _on_stealth_char_health_depleted():
	%LevelFailed.visible = true
	get_tree().paused = true


func _on_gloves_artefact_picked_up():
	final_artefact_collected = true


func _on_run_once_timer_timeout():
	_run_once()


func _input(_event):
	if Input.is_action_just_pressed("escape"):
		pause_game()
		
func pause_game():
	$PauseMenuLayer.visible = true
	get_tree().paused = true

extends Node2D

var pearls_collected = 0
var final_artefact_collected = false

# similar to _ready, but is run 0.1s after the scene is loaded
# cannot use _ready as some child nodes may not be loaded yet
func _run_once():
	set_patrol_state()
	%LevelPassed.visible = false
	%LevelFailed.visible = false
	Global.gloves_equipped = false

# Enemy class public method
func set_patrol_state():
	%Guard.set_rotate_patrol(80)
	%Guard4.set_rotate_patrol(55)

# triggered when player enters exit portal area
func _on_purple_portal_level_passed():
	if final_artefact_collected:
		%LevelPassed.visible = true
		get_tree().paused = true

# does not have any use for now
func _on_purple_pearl_pearl_picked_up():
	pearls_collected += 1
	#print("pearl")

# triggered when player health is <= 0, signal from character
func _on_stealth_char_health_depleted():
	%LevelFailed.visible = true
	get_tree().paused = true


func _on_gloves_artefact_picked_up():
	final_artefact_collected = true


func _on_run_once_timer_timeout():
	_run_once()

# detects for esc key pressed
func _input(_event):
	if Input.is_action_just_pressed("escape"):
		pause_game()
		
func pause_game():
	$PauseMenuLayer.visible = true
	get_tree().paused = true

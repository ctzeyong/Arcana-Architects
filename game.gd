extends Node2D

var pearls_collected = 0



#func _process(delta):
	#%LevelPassed.visible = false


func _on_purple_portal_level_passed():
	%LevelPassed.visible = true
	get_tree().paused = true


func _on_purple_pearl_pearl_picked_up():
	pearls_collected += 1
	print("pearl")
	


func _on_stealth_char_health_depleted():
	%LevelFailed.visible = true
	get_tree().paused = true

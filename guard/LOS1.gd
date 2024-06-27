extends RayCast2D

#signal player_detected

func _process(delta):
	if is_colliding():
		#player_detected.emit()
		print("seen")

extends PathFollow2D

var movement_speed = 50

func _physics_process(delta):
	progress += movement_speed * delta
	#if progress_ratio > 0.49 && progress_ratio < 0.51:
		#print("turn")




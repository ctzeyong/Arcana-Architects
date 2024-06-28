extends PathFollow2D

var movement_speed = 50
var turn_complete = true

func _physics_process(delta):
	progress += movement_speed * delta
	#if (progress_ratio > 0.29 and progress_ratio < 0.31) or (progress_ratio > 0.79 and progress_ratio < 0.81):
		#turn_complete = false
		#print("false")
	#if (progress_ratio > 0.49 and progress_ratio < 0.51) or (progress_ratio > 0.98 and progress_ratio < 0.02):
		#if (turn_complete == false):
			#print("turn")
			#turn_complete = true




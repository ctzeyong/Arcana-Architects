extends StaticBody2D

var time

func _ready():
	time = %Timer.get_wait_time()
	%Timer.stop()

func _physics_process(delta):
	if %Timer.is_stopped():
		%ProgressBar.value = 0
	else:
		%ProgressBar.value = 1 - %Timer.get_time_left() / time
	
	if %UnlockBox.get_overlapping_bodies() and Input.is_action_pressed("unlock"):
		if %Timer.is_stopped():
			%Timer.start()
	else:
		%Timer.stop()
			


func _on_timer_timeout():
	queue_free()

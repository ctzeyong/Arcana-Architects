extends StaticBody2D

var time
var gloves := false

func _ready():
	%ProgressBar.visible = false
	time = %Timer.get_wait_time()
	%Timer.stop()

func _physics_process(delta):
	if %Timer.is_stopped():
		%ProgressBar.value = 0
	else:
		%ProgressBar.value = 1 - %Timer.get_time_left() / time
	
	if %UnlockBox.get_overlapping_bodies():
		%ProgressBar.visible = true
		if Input.is_action_pressed("use_item") and Global.gloves_unlock_left and Global.gloves_equipped:
			queue_free()
			Global.gloves_unlock_left -= 1
		if Input.is_action_pressed("unlock"):
			if %Timer.is_stopped():
				%Timer.start()
	else:
		%Timer.stop()
		%ProgressBar.visible = false
	


func _on_timer_timeout():
	queue_free()

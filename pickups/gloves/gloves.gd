extends Area2D

signal artefact_picked_up

# if character moves into collision area, disappear
func _on_body_entered(body):
	artefact_picked_up.emit()
	%GlovesAnim.pick_up_anim()
	%Timer.start()
	


func _on_timer_timeout():
	queue_free()

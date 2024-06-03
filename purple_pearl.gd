extends Area2D

signal pearl_picked_up

# if character moves into collision area, disappear
func _on_body_entered(body):
	pearl_picked_up.emit()
	queue_free()

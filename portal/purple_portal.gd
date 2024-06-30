extends Area2D

signal level_passed

func _on_body_entered(body):
	print("Portal")
	level_passed.emit()

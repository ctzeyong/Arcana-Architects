extends Area2D

signal level_passed

func _on_body_entered(body):
	print("You passed the maze!")
	level_passed.emit()

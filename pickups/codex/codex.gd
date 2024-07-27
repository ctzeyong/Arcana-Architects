extends Area2D

signal artefact_picked_up

func _ready():
	%AnimationPlayer.play("idle")

# if character moves into collision area, disappear
func _on_body_entered(body):
	artefact_picked_up.emit()
	%AnimationPlayer.play("pickup")
	%Timer.start()


func _on_timer_timeout():
	queue_free()

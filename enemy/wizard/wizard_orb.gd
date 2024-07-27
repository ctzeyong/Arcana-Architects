extends Area2D

var target_destination

const SPEED = 300
const RANGE = 1000

func _physics_process(delta):
	var direction = target_destination - global_position
	direction = direction.normalized()
	position += direction * SPEED * delta
	
	var pos_reached = global_position.distance_to(target_destination) < 3.0
	if pos_reached:
		queue_free()
	

func _on_body_entered(body):
	queue_free()
	if body.has_method("take_damage"):
		body.take_damage(50)


func _on_timer_timeout():
	queue_free()

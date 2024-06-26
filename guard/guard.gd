extends CharacterBody2D

@onready var player = get_node("/root/@Node2D@2/StealthChar")

func _physics_process(delta):
	var direction = global_position.direction_to(player.global_position)
	velocity = direction * 300
	move_and_slide()

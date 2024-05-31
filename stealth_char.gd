extends CharacterBody2D

const SPEED = 100
var last_direction = 0;

func _physics_process(delta):
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * 100
	
	if direction.y < 0:
		%StealthCharAnim.walk_up_anim()
		last_direction = 0;
	elif direction.y > 0:
		%StealthCharAnim.walk_down_anim()
		last_direction = 1;
	elif direction.x < 0:
		%StealthCharAnim.walk_left_anim()
		last_direction = 2;
	elif direction.x > 0:
		%StealthCharAnim.walk_right_anim()
		last_direction = 3;
	else:
		match last_direction:
			0: 
				%StealthCharAnim.idle_up_anim()
			1:
				%StealthCharAnim.idle_down_anim()
			2:
				%StealthCharAnim.idle_left_anim()
			3:
				%StealthCharAnim.idle_right_anim()

	move_and_slide()

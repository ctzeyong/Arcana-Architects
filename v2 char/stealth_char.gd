extends CharacterBody2D

const BASE_SPEED = 100
const SPRINT_MULTIPLIER = 2
var last_direction = 0 
# to decide idle animation, 0 1 2 3 correspond to up down left right 
var health = 100.0

signal health_depleted

func _physics_process(delta):
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	# map wasd to character movement
	var speed = BASE_SPEED
	var is_sprinting = Input.is_action_pressed("sprint_active")
	# detect if shift key is held down
	if is_sprinting:
		speed *= SPRINT_MULTIPLIER
	velocity = direction * speed
	
	if direction.y < 0:
		# character is moving up
		last_direction = 0;
		if is_sprinting:
			%StealthCharAnim.sprint_up_anim()
		else:
			%StealthCharAnim.walk_up_anim()
	elif direction.y > 0:
		# character is moving down
		last_direction = 1;
		if is_sprinting:
			%StealthCharAnim.sprint_down_anim()
		else:
			%StealthCharAnim.walk_down_anim()
	elif direction.x < 0:
		# character is moving left
		last_direction = 2;
		if is_sprinting:
			%StealthCharAnim.sprint_left_anim()
		else:
			%StealthCharAnim.walk_left_anim()
	elif direction.x > 0:
		# character is moving right
		last_direction = 3;
		if is_sprinting:
			%StealthCharAnim.sprint_right_anim()
		else:
			%StealthCharAnim.walk_right_anim()
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
	
	var guard_overlap = %Hitbox.get_overlapping_bodies() # Layer 8 instant death
	if guard_overlap.size() > 0:
		health -= 1000 * delta
		print("damage")
	if health <= 0:
		health_depleted.emit()


func _on_hitbox_body_entered(body):
	print("death")
	health_depleted.emit()

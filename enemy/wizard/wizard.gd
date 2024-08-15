extends Enemy

func _ready():
	player = Global.player
	if player == null:
		push_error("Player node not found")
	#else:
		#print("Player found")
	visual_box = Global.visual_box
	
	original_position = global_position
	original_rotation = rotation
	
	angle_cone_of_vision = deg_to_rad(96.0)
	max_view_distance = 150.0
	angle_between_rays = deg_to_rad(3)
	rotation_speed = 5.0
	patrol_rotation_speed = 0.8
	walking_rotation_speed = 4.0
	chase_speed = 4000
	walk_speed = 3500
	rot_tolerance = 1.0
	pos_tolerance = 2.0
	
	state = State.PATROL
	p_state = P_State.STATIC
	
	generate_raycasts()
	generate_attack_raycasts()
	%WizardAnim.idle_anim()
	
	%DetectBox/CollisionShape2D.shape.set_radius(max_view_distance)


func _physics_process(delta):
	move_and_slide()
	draw_sight_cone()
	
	match state:
		State.PATROL:
			velocity = Vector2.ZERO
			%SightCone.set_color(LIGHT_CYAN)
			%WizardAnim.idle_anim()
			if %DetectBox.get_overlapping_bodies():
				if detect_player(delta):
					state = State.CHASE
					return
			match p_state:
				P_State.STATIC:
					return
				P_State.ROTATE:
					rotate_patrol(delta)
		State.INVESTIGATE:
			%SightCone.set_color(GOLD)
			%WizardAnim.walk_anim()
			investigate_player(delta)
			if detect_player(delta):
				state = State.CHASE
				player_pos = null
		State.SEEK:
			%SightCone.set_color(GOLD)
			%WizardAnim.idle_anim()
			seek_player(delta)
			if detect_player(delta):
				state = State.CHASE
				%SeekTimer.stop()
		State.CHASE:
			%SightCone.set_color(LIGHT_CORAL)
			%WizardAnim.walk_anim()
			chase_player(delta)
			if player_in_attack_range(delta):
				state = State.ATTACK
				return
			if !detect_player(delta):
				state = State.LOST_SIGHT
		State.LOST_SIGHT:
			%SightCone.set_color(LIGHT_CORAL)
			if lost_player(delta):
				state = State.SEEK
				%SeekTimer.start()
				return
			chase_player(delta)
			if detect_player(delta):
				state = State.CHASE
		State.ATTACK:
			attack_player(delta)
			if !player_in_attack_range(delta):
				state = State.CHASE
			if !detect_player(delta):
				state = State.LOST_SIGHT
		State.RETURN:
			%SightCone.set_color(LIGHT_CYAN)
			%WizardAnim.walk_anim()
			return_to_original(delta)
			if %DetectBox.get_overlapping_bodies():
				if detect_player(delta):
					state = State.CHASE


func attack_player(delta) -> void:
	velocity = Vector2.ZERO
	var direction = global_position.direction_to(player.global_position)
	direction = direction.normalized()
	
	var angle_to = transform.x.angle_to(direction)
	rotate(sign(angle_to) * min(delta * rotation_speed, abs(angle_to)))
	if ammo_loaded:
		%WizardAnim.attack_anim()
		ammo_loaded = false
		shoot()
		%AttackTimer.start()


func shoot() -> void:
	const ORB = preload("res://enemy/wizard/wizard_orb.tscn")
	var new_orb = ORB.instantiate()
	new_orb.global_position = global_position
	new_orb.target_destination = player.global_position
	get_tree().root.add_child(new_orb)

# in tandem with rotate_patrol
func _on_rotate_timer_timeout():
	match rotation_state:
		2:
			rotation_state = 3
		4:
			rotation_state = 1

# in tandem with seek_player
func _on_seek_timer_timeout():
	match rotation_state:
		2:
			rotation_state = 3
		4:
			rotation_state = 1
			state = State.RETURN

# manage attack speed
func _on_attack_timer_timeout():
	ammo_loaded = true

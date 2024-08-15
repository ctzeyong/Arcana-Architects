extends Enemy

func _ready():
	player = Global.player # maps the player node in global script
	if player == null:
		push_error("Player node not found")
	#else:
		#print("Player found")
	visual_box = Global.visual_box # get character's visual box
	
	original_position = global_position
	original_rotation = rotation
	
	angle_cone_of_vision = deg_to_rad(96.0)
	max_view_distance = 150.0
	angle_between_rays = deg_to_rad(3)
	rotation_speed = 5.0
	patrol_rotation_speed = 0.8
	walking_rotation_speed = 4.0
	chase_speed = 8000
	walk_speed = 3500
	rot_tolerance = 1.0
	pos_tolerance = 2.0
	
	generate_raycasts()
	%GuardAnim.idle_right_anim()
	
	%DetectBox/CollisionShape2D.shape.set_radius(max_view_distance)


func _physics_process(delta):
	move_and_slide()
	draw_sight_cone()
	
	match state:
		State.PATROL:
			#print("patrol")
			velocity = Vector2.ZERO
			%SightCone.set_color(LIGHT_CYAN)
			%GuardAnim.idle_right_anim()
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
			%GuardAnim.walk_right_anim()
			investigate_player(delta)
			if detect_player(delta):
				state = State.CHASE
				player_pos = null
		State.SEEK:
			%SightCone.set_color(GOLD)
			%GuardAnim.idle_right_anim()
			seek_player(delta)
			if detect_player(delta):
				state = State.CHASE
				%SeekTimer.stop()
		State.CHASE:
			%SightCone.set_color(LIGHT_CORAL)
			%GuardAnim.sprint_right_anim()
			chase_player(delta)
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
		State.RETURN:
			%SightCone.set_color(LIGHT_CYAN)
			%GuardAnim.walk_right_anim()
			return_to_original(delta)
			if %DetectBox.get_overlapping_bodies():
				if detect_player(delta):
					state = State.CHASE


# in tandem with seek_player
func _on_seek_timer_timeout():
	match rotation_state:
		2:
			rotation_state = 3
		4:
			rotation_state = 1
			state = State.RETURN

# in tandem with rotate_patrol
func _on_rotate_timer_timeout():
	match rotation_state:
		2:
			rotation_state = 3
		4:
			rotation_state = 1

# if character enters the attack box
func _on_attack_box_body_entered(body):
	if body.has_method("take_damage"):
		body.take_damage(1000)





extends CharacterBody2D

#@onready var player = get_node("/root/@Node2D@7/StealthChar")
@onready var original_position := global_position
@onready var original_rotation := rotation

var player_pos = null
var player = null
var visual_box = null
var last_rotation
const angle_cone_of_vision := deg_to_rad(90.0)
const max_view_distance := 110.0
const angle_between_rays := deg_to_rad(3)
const rotation_speed := 5.0
const patrol_rotation_speed := 0.8
const walking_rotation_speed := 4.0
const chase_speed := 5000
const walk_speed := 3000
const rot_tolerance := 1.0
const pos_tolerance := 2.0

const LIGHT_CYAN := Color(0.878431, 1, 1, 0.1)
const LIGHT_CORAL := Color(0.941176, 0.501961, 0.501961, 0.1)
const GOLD := Color(1, 0.843137, 0, 0.1)

enum State { PATROL, INVESTIGATE, SEEK, CHASE, LOST_SIGHT, RETURN }
var state := State.PATROL

enum P_State { STATIC, ROTATE, FOLLOW_PATH }
var p_state := P_State.STATIC

var rotation_state := 1
var patrol_rotation_angle := deg_to_rad(60.0)

var chase_raycasts = []
var sight_raycasts = []
var raycast_points: PackedVector2Array = []

func _ready():
	player = Global.player
	if player == null:
		push_error("Player node not found")
	else:
		print("Player found")
	visual_box = Global.visual_box
	generate_raycasts()
	%GuardAnim.idle_right_anim()
	

func set_rotate_patrol(angle): # called by game scene
	p_state = P_State.ROTATE
	rotation_state = 1
	patrol_rotation_angle = deg_to_rad(angle)


func generate_raycasts(): # many raycasts as cone of sight
	var ray_count = angle_cone_of_vision / angle_between_rays
	
	for i in (ray_count + 1): # generate raycasts for normal sight of player
		var ray := RayCast2D.new()
		var angle = angle_between_rays * (i - ray_count / 2.0)
		ray.target_position = Vector2.RIGHT.rotated(angle) * max_view_distance # starting position face right
		ray.set_collision_mask_value(1, true)
		ray.set_collision_mask_value(2, true)
		ray.set_collide_with_bodies(true)
		add_child(ray)
		ray.enabled = true
		chase_raycasts.append(ray)
	
	for i in ((ray_count / 2) + 1): # generate raycasts to detect visual box of player
		var ray := RayCast2D.new()
		var angle = (angle_between_rays * 2) * (i - ((ray_count / 2) / 2.0))
		ray.target_position = Vector2.RIGHT.rotated(angle) * (max_view_distance)# starting position face right
		ray.set_collision_mask_value(1, true)
		ray.set_collision_mask_value(2, true)
		ray.set_collide_with_bodies(true)
		ray.set_collide_with_areas(true)
		add_child(ray)
		ray.enabled = true
		sight_raycasts.append(ray)


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
				#print("player in area")
				if detect_player(delta):
					state = State.CHASE
					return
			if %AlertBox.get_overlapping_areas():
				state = State.INVESTIGATE
				return
			match p_state:
				P_State.STATIC:
					pass
				P_State.ROTATE:
					rotate_patrol(delta)
		State.INVESTIGATE:
			#print("investigate")
			%SightCone.set_color(GOLD)
			investigate_player(delta)
			if detect_player(delta):
				state = State.CHASE
				player_pos = null
				return
			if %AlertBox.get_overlapping_areas():
				player_pos = player.global_position
				%NavigationAgent2D.target_position = player_pos
		State.SEEK:
			#print("player seeking")
			%SightCone.set_color(GOLD)
			seek_player(delta)
			if detect_player(delta):
				state = State.CHASE
				%SeekTimer.stop()
				return
			if %AlertBox.get_overlapping_areas():
				state = State.INVESTIGATE
				%SeekTimer.stop()
		State.CHASE:
			print("player detected")
			%SightCone.set_color(LIGHT_CORAL)
			chase_player(delta)
			if !detect_player(delta):
				state = State.LOST_SIGHT
				#%ChaseTimer.start()
		State.LOST_SIGHT:
			print("player sight lost")
			%SightCone.set_color(LIGHT_CORAL)
			if lost_player(delta):
				state = State.SEEK
				%SeekTimer.start()
				return
			chase_player(delta)
			if detect_player(delta):
				state = State.CHASE
				#%ChaseTimer.stop()
				return
			if %AlertBox.get_overlapping_areas():
				state = State.INVESTIGATE
				return
			
		State.RETURN:
			#print("return to original")
			%SightCone.set_color(LIGHT_CYAN)
			return_to_original(delta)
			if %DetectBox.get_overlapping_bodies():
				if detect_player(delta):
					state = State.CHASE
					return
			if %AlertBox.get_overlapping_areas():
				state = State.INVESTIGATE


func seek_player(delta):
	%GuardAnim.idle_right_anim()
	var rot_reached
	match rotation_state:
		1:
			#print("1")
			rotate(-patrol_rotation_speed * delta)
			if abs(rotation - (last_rotation - deg_to_rad(60))) > deg_to_rad(360):
				rot_reached = abs(rotation - (last_rotation - deg_to_rad(60))) - deg_to_rad(360) < deg_to_rad(rot_tolerance)
			else:
				rot_reached = abs(rotation - (last_rotation - deg_to_rad(60))) < deg_to_rad(rot_tolerance)
			if rot_reached:
				rotation_state = 2
				%SeekTimer.start()
		3:
			#print("3")
			rotate(patrol_rotation_speed * delta)
			if abs(rotation - (last_rotation - deg_to_rad(60))) > deg_to_rad(360):
				rot_reached = abs(rotation - (last_rotation - deg_to_rad(60))) - deg_to_rad(360) < deg_to_rad(rot_tolerance)
			else:
				rot_reached = abs(rotation - (last_rotation - deg_to_rad(60))) < deg_to_rad(rot_tolerance)
			if rot_reached:
				rotation_state = 4
				%SeekTimer.start()

func _on_seek_timer_timeout():
	match rotation_state:
		2:
			print("2")
			rotation_state = 3
		4:
			rotation_state = 1
			state = State.RETURN


func investigate_player(delta):
	if player_pos == null:
		player_pos = player.global_position
		%NavigationAgent2D.target_position = player_pos
	var current_pos = global_position
	var pos_reached = current_pos.distance_to(player_pos) < pos_tolerance
	if pos_reached:
		position = player_pos
		velocity = Vector2.ZERO
		state = State.SEEK
		player_pos = null
		last_rotation = rotation
		%SeekTimer.start()
		return
				
	var next_path_pos = %NavigationAgent2D.get_next_path_position()
	var direction = global_position.direction_to(next_path_pos)
	direction = direction.normalized()
	
	var angle_to = transform.x.angle_to(direction)
	rotate(sign(angle_to) * min(delta * walking_rotation_speed, abs(angle_to)))
	
	velocity = direction * walk_speed * delta
	%GuardAnim.walk_right_anim()


func detect_player(delta):
	for ray in chase_raycasts:
		if ray is RayCast2D:
			if ray.is_colliding() and ray.get_collider() == player:
				%NavigationAgent2D.target_position = ray.get_collision_point()
				player_pos = ray.get_collision_point()
				return true
	return false


func chase_player(delta):
	#var direction = player.global_position - global_position
	#direction = direction.normalized()
	
	var next_path_pos = %NavigationAgent2D.get_next_path_position()
	var direction = global_position.direction_to(next_path_pos)
	direction = direction.normalized()
	
	var angle_to = transform.x.angle_to(direction)
	rotate(sign(angle_to) * min(delta * rotation_speed, abs(angle_to)))
	
	velocity = direction * chase_speed * delta
	%GuardAnim.sprint_right_anim()

func _on_chase_timer_timeout():
	state = State.RETURN


func lost_player(delta):
	for ray in sight_raycasts:
		if ray is RayCast2D:
			if ray.is_colliding() and ray.get_collider() == visual_box:
				%NavigationAgent2D.target_position = ray.get_collision_point()
				player_pos = ray.get_collision_point()
				return false
	var current_pos = global_position
	var pos_reached = current_pos.distance_to(player_pos) < pos_tolerance + 5
	if pos_reached:
		position = player_pos
		velocity = Vector2.ZERO
		player_pos = null
		last_rotation = rotation
		return true
	return false


func return_to_original(delta):
	var direction
	var angle_to
	var current_pos = global_position
	var pos_reached = current_pos.distance_to(original_position) < 2
	var rot_reached = abs(rotation - original_rotation) < deg_to_rad(2)
	
	if pos_reached:
		#print("area")
		%GuardAnim.idle_right_anim()
		velocity = Vector2.ZERO
		if rot_reached:
			position = original_position
			rotation = original_rotation
			state = State.PATROL
			return
		angle_to = original_rotation - rotation
		rotate(sign(angle_to) * min(delta * patrol_rotation_speed, abs(angle_to)))
		return
	
	%NavigationAgent2D.target_position = original_position
	var next_path_pos = %NavigationAgent2D.get_next_path_position()
	direction = global_position.direction_to(next_path_pos)
	direction = direction.normalized()
	
	angle_to = transform.x.angle_to(direction)
	rotate(sign(angle_to) * min(delta * walking_rotation_speed, abs(angle_to)))
	
	velocity = direction * walk_speed * delta
	%GuardAnim.walk_right_anim()


func rotate_patrol(delta):
	var rot_reached
	match rotation_state:
		1:
			rotate(-patrol_rotation_speed * delta)
			if abs(rotation - (original_rotation - patrol_rotation_angle)) >= deg_to_rad(360):
				rot_reached = abs(rotation - (original_rotation - patrol_rotation_angle)) - deg_to_rad(360) < deg_to_rad(rot_tolerance)
			else:
				rot_reached = abs(rotation - (original_rotation - patrol_rotation_angle)) < deg_to_rad(rot_tolerance)
			if rot_reached:
				rotation_state = 2
				%RotateTimer.start()
		3:
			rotate(patrol_rotation_speed * delta)
			if abs(rotation - (original_rotation - patrol_rotation_angle)) > deg_to_rad(360):
				rot_reached = abs(rotation - (original_rotation + patrol_rotation_angle)) - deg_to_rad(360) < deg_to_rad(rot_tolerance)
			else:
				rot_reached = abs(rotation - (original_rotation + patrol_rotation_angle)) < deg_to_rad(rot_tolerance)
			if rot_reached:
				rotation_state = 4
				%RotateTimer.start()


func _on_rotate_timer_timeout():
	match rotation_state:
		2:
			rotation_state = 3
		4:
			rotation_state = 1


func _on_attack_box_body_entered(body):
	if body.has_method("take_damage"):
		body.take_damage(1000)


func _draw():
	draw_sight_cone()


func draw_sight_cone():
	#print("draw")
	raycast_points.clear()
	raycast_points.append(Vector2.ZERO)
	for ray in chase_raycasts:
		if ray is RayCast2D:
			if ray.is_colliding():
				raycast_points.append(to_local(ray.get_collision_point()))
			else:
				raycast_points.append(ray.target_position)
	%SightCone.set_polygon(raycast_points) 


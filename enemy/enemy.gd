class_name Enemy
extends CharacterBody2D

var original_position := global_position
var original_rotation := rotation
var player_pos = null
var player = null
var visual_box = null
var last_rotation

var angle_cone_of_vision : float = deg_to_rad(96.0)
var max_view_distance : float = 150.0
var angle_between_rays : float = deg_to_rad(3)
var attack_distance : float = 100.0

var rotation_speed : float = 5.0
var patrol_rotation_speed : float = 0.8
var walking_rotation_speed : float = 4.0
var chase_speed := 8000
var walk_speed := 3500
var rot_tolerance : float = 1.0
var pos_tolerance : float = 2.0

var ammo_loaded : bool = true

const LIGHT_CYAN := Color(0.878431, 1, 1, 0.15)
const LIGHT_CORAL := Color(0.941176, 0.501961, 0.501961, 0.15)
const GOLD := Color(1, 0.843137, 0, 0.15)

enum State { PATROL, INVESTIGATE, SEEK, CHASE, LOST_SIGHT, ATTACK, RETURN }
var state := State.PATROL

enum P_State { STATIC, ROTATE, FOLLOW_PATH }
var p_state := P_State.STATIC

var rotation_state : int = 1
var patrol_rotation_angle : float = deg_to_rad(60.0)

var chase_raycasts = []
var sight_raycasts = []
var attack_raycasts = []
var raycast_points: PackedVector2Array = []


func set_rotate_patrol(angle) -> void: # called by game scene
	p_state = P_State.ROTATE
	rotation_state = 1
	patrol_rotation_angle = deg_to_rad(angle)


func generate_raycasts() -> void: # many raycasts as cone of sight
	var ray_count = (angle_cone_of_vision / angle_between_rays)
	
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


func generate_attack_raycasts() -> void:
	var ray_count = (angle_cone_of_vision / angle_between_rays)
	
	for i in ((ray_count / 2) + 1): # generate raycasts to detect visual box of player
		var ray := RayCast2D.new()
		var angle = (angle_between_rays * 2) * (i - ((ray_count / 2) / 2.0))
		ray.target_position = Vector2.RIGHT.rotated(angle) * attack_distance# starting position face right
		ray.set_collision_mask_value(1, true)
		ray.set_collision_mask_value(2, true)
		ray.set_collide_with_bodies(true)
		add_child(ray)
		ray.enabled = true
		attack_raycasts.append(ray)


func draw_sight_cone() -> void:
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


func rotate_patrol(delta) -> void:
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


func investigate_player(delta) -> void:
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


func player_is_near() -> void:
	if state == State.INVESTIGATE:
		player_pos = player.global_position
		%NavigationAgent2D.target_position = player_pos
	else:
		state = State.INVESTIGATE
		%SeekTimer.stop()


func seek_player(delta) -> void:
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


func detect_player(delta) -> bool:
	for ray in chase_raycasts:
		if ray is RayCast2D:
			if ray.is_colliding() and ray.get_collider() == player:
				%NavigationAgent2D.target_position = ray.get_collision_point()
				player_pos = ray.get_collision_point()
				return true
	return false


func chase_player(delta) -> void:
	var next_path_pos = %NavigationAgent2D.get_next_path_position()
	var direction = global_position.direction_to(next_path_pos)
	direction = direction.normalized()
	
	var angle_to = transform.x.angle_to(direction)
	rotate(sign(angle_to) * min(delta * rotation_speed, abs(angle_to)))
	
	velocity = direction * chase_speed * delta


func lost_player(delta) -> bool:
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


func player_in_attack_range(delta) -> bool:
	for ray in attack_raycasts:
		if ray is RayCast2D:
			if ray.is_colliding() and ray.get_collider() == player:
				%NavigationAgent2D.target_position = ray.get_collision_point()
				player_pos = ray.get_collision_point()
				return true
	return false


func return_to_original(delta) -> void:
	var direction
	var angle_to
	var current_pos = global_position
	var pos_reached = current_pos.distance_to(original_position) < 2
	var rot_reached = abs(rotation - original_rotation) < deg_to_rad(2)
	
	if pos_reached:
		#print("area")
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


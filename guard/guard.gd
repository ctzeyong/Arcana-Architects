extends CharacterBody2D

#@onready var player = get_node("/root/@Node2D@7/StealthChar")
@onready var last_position = global_position
@onready var original_rotation = rotation

var player = null
const angle_cone_of_vision = deg_to_rad(95.0)
const max_view_distance = 97.0
const angle_between_rays = deg_to_rad(5)
const rotation_speed = 2.0
const patrol_rotation_speed = 0.8
const chase_speed = 150


enum State { PATROL, CHASE, LOST_SIGHT }
var state = State.PATROL

enum P_State { STATIC, ROTATE, FOLLOW_PATH }
var p_state = P_State.STATIC

var rotation_state = 0
var patrol_rotation_angle = deg_to_rad(60.0)

var raycasts = []
var raycast_points = []

func _ready():
	player = Global.player
	if player == null:
		print("Player node not found")
	else:
		print("Player found")
	generate_raycasts()
	%GuardAnim.idle_right_anim()

func set_rotate_patrol(angle): # called by game scene
	p_state = P_State.ROTATE
	rotation_state = 1
	patrol_rotation_angle = deg_to_rad(angle)


func generate_raycasts(): # many raycasts as cone of sight
	var ray_count = angle_cone_of_vision / angle_between_rays
	
	for i in ray_count:
		var ray = RayCast2D.new()
		var angle = angle_between_rays * (i - ray_count / 2.0)
		ray.target_position = Vector2.RIGHT.rotated(angle) * max_view_distance # starting position face right
		ray.set_collision_mask_value(1, true)
		add_child(ray)
		ray.enabled = true
		raycasts.append(ray)


func _physics_process(delta):
	move_and_slide()
	#raycast_points.clear()
	#for ray in get_children():
		#if ray is RayCast2D:
			#if ray.is_colliding():
				#raycast_points.append(ray.get_collision_point())
			#else:
				#raycast_points.append(ray.global_position + ray.target_position)
	#
	#queue_redraw()
	
	match state:
		State.PATROL:
			#print("patrol")
			%SightCone.set_color(Color(0.878431, 1, 1, 0.2))
			%GuardAnim.idle_right_anim()
			if %DetectBox.get_overlapping_bodies():
				#print("player in area")
				if detect_player(delta):
					state = State.CHASE
			if %AlertBox.get_overlapping_areas():
				state = State.CHASE
			match p_state:
				P_State.STATIC:
					pass
				P_State.ROTATE:
					rotate_patrol(delta)
		State.CHASE:
			#print("player detected")
			%SightCone.set_color(Color(0.941176, 0.501961, 0.501961, 0.2))
			chase_player(delta)
			if !detect_player(delta):
				state = State.LOST_SIGHT
				%ChaseTimer.start()
		State.LOST_SIGHT:
			#print("player sight lost")
			%SightCone.set_color(Color(0.941176, 0.501961, 0.501961, 0.2))
			chase_player(delta)
			if detect_player(delta):
				state = State.CHASE
				%ChaseTimer.stop()


func detect_player(delta):
	for ray in get_children():
		if ray is RayCast2D:
			if ray.is_colliding() and ray.get_collider() == player:
				return true
	return false


func chase_player(delta):
	var direction = player.global_position - global_position
	direction = direction.normalized()
	
	var angle_to = transform.x.angle_to(direction)
	rotate(sign(angle_to) * min(delta * rotation_speed, abs(angle_to)))
	
	velocity = direction * chase_speed
	%GuardAnim.sprint_right_anim()



func _on_chase_timer_timeout():
	position = last_position
	rotation = original_rotation
	state = State.PATROL


func rotate_patrol(delta):
	match rotation_state:
		1:
			rotate(-patrol_rotation_speed * delta)
			if rotation <= original_rotation - patrol_rotation_angle:
				rotation_state = 2
				%RotateTimer.start()
		3:
			rotate(patrol_rotation_speed * delta)
			if rotation >= original_rotation + patrol_rotation_angle:
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
	print("draw")
	var global_pos = global_position
	var points = [global_pos] + raycast_points + [global_pos]
	var color = Color(1, 1, 1, 0.3)
	
	draw_colored_polygon(points, color)

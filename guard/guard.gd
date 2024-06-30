extends CharacterBody2D

@onready var player = get_node("/root/@Node2D@2/StealthChar")
@onready var last_position = global_position
@onready var original_rotation = rotation

const angle_cone_of_vision = deg_to_rad(10.0)
const max_view_distance = 100.0
const angle_between_rays = deg_to_rad(10.0)
const rotation_speed = 2.0
const patrol_rotation_speed = 1.0
const chase_speed = 150


enum State { PATROL, CHASE, LOST_SIGHT }
var state = State.PATROL

enum P_State { STATIC, ROTATE, FOLLOW_PATH }
var p_state = P_State.STATIC

var rotation_state = 0
var patrol_rotation_angle = deg_to_rad(60.0)

func _ready():
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
		
		#var line = Line2D.new()
		#line.default_color = Color(1,0,0)
		#line.width = 2.0
		#add_child(line)


func _physics_process(delta):
	move_and_slide()
	#for ray in get_children():
		#if ray is RayCast2D:
			#update_line(ray)
	match state:
		State.PATROL:
			#print("patrol")
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
			print("player detected")
			chase_player(delta)
			if !detect_player(delta):
				state = State.LOST_SIGHT
				%ChaseTimer.start()
		State.LOST_SIGHT:
			print("player sight lost")
			chase_player(delta)
			if detect_player(delta):
				state = State.CHASE
				%ChaseTimer.stop()


func update_line(ray):
	for line in get_children():
		if line is Line2D:
			line.points = [ray.global_position, ray.to_global(ray.target_position)]


func detect_player(delta):
	for ray in get_children():
		if ray is RayCast2D:
			if ray.is_colliding() and ray.get_collider() == player:
				return true
	return false


func chase_player(delta):
	last_position = global_position
	var direction = player.global_position - global_position
	direction = direction.normalized()
	
	var angle_to = transform.x.angle_to(direction)
	rotate(sign(angle_to) * min(delta * rotation_speed, abs(angle_to)))
	
	velocity = direction * chase_speed
	%GuardAnim.sprint_right_anim()



func _on_chase_timer_timeout():
	position = last_position
	state = State.PATROL


func rotate_patrol(delta):
	match rotation_state:
		1:
			#print("1")
			#var target_rotation = original_rotation - patrol_rotation_angle
			#rotation = lerp_angle(rotation, target_rotation, patrol_rotation_speed * delta)
			#if abs(rotation - target_rotation) < 0.01:
				#rotation = target_rotation
				#rotation_state = 2
				#%RotateTimer.start()
			rotate(-patrol_rotation_speed * delta)
			if rotation <= original_rotation - patrol_rotation_angle:
				rotation_state = 2
				%RotateTimer.start()
		3:
			#print("3")
			#var target_rotation = original_rotation + patrol_rotation_angle
			#rotation = lerp_angle(rotation, target_rotation, patrol_rotation_speed * delta)
			#if abs(rotation - target_rotation) < 0.01:
				#rotation = target_rotation
				#rotation_state = 4
				#%RotateTimer.start()
			rotate(patrol_rotation_speed * delta)
			if rotation >= original_rotation + patrol_rotation_angle:
				rotation_state = 4
				%RotateTimer.start()
		#5:
			#print("5")
			#rotate(-min(patrol_rotation_speed * delta, deg_to_rad(45)))
			#if rotation <= deg_to_rad(1) and rotation >= -deg_to_rad(1):
				#rotation_state = 1


func _on_rotate_timer_timeout():
	match rotation_state:
		2:
			rotation_state = 3
		4:
			rotation_state = 1

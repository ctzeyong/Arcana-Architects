extends CharacterBody2D

@onready var player = get_node("/root/@Node2D@2/StealthChar")
@onready var last_position = global_position

const angle_cone_of_vision = deg_to_rad(140.0)
const max_view_distance = 100.0
const angle_between_rays = deg_to_rad(10.0)
const rotation_speed = 2.0
const patrol_speed = 75
const chase_speed = 150


enum State { PATROL, CHASE, LOST_SIGHT }
var state = State.PATROL


func _ready():
	generate_raycasts()
	%GuardAnim.idle_right_anim()


func is_patrol_active():
	return state == State.PATROL


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
			print("patrol")
			%GuardAnim.idle_right_anim()
			if %DetectBox.get_overlapping_bodies():
				#print("player in area")
				if detect_player(delta):
					state = State.CHASE
			if %AlertBox.get_overlapping_areas():
				state = State.CHASE
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
				#chase_player(delta)
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

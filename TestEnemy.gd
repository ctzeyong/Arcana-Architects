extends CharacterBody2D

#@onready var player = get_node("/root/@Node2D@7/StealthChar")
@onready var original_position = global_position
@onready var original_rotation = rotation

var player = null
var visual_box = null
const angle_cone_of_vision = deg_to_rad(95.0)
const max_view_distance = 97.0
const angle_between_rays = deg_to_rad(5)
const rotation_speed = 5.0
const patrol_rotation_speed = 0.8
const chase_speed = 100
const walk_speed = 75

const LIGHT_CYAN = Color(0.878431, 1, 1, 0.2)
const LIGHT_CORAL = Color(0.941176, 0.501961, 0.501961, 0.2)

enum State { PATROL, SEEK, CHASE, LOST_SIGHT, RETURN }
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
	visual_box = Global.visual_box
	generate_raycasts()
	$BaseSkeletonAnim.play_idle()


func generate_raycasts(): # many raycasts as cone of sight
	var ray_count = angle_cone_of_vision / angle_between_rays
	
	for i in ray_count:
		var ray = RayCast2D.new()
		var angle = angle_between_rays * (i - ray_count / 2.0)
		ray.target_position = Vector2.RIGHT.rotated(angle) * max_view_distance # starting position face right
		ray.set_collision_mask_value(1, true)
		ray.set_collision_mask_value(2, true)
		#ray.set_collide_with_areas(true)
		ray.set_collide_with_bodies(true)
		add_child(ray)
		ray.enabled = true
		#raycasts.append(ray)


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
	
	if detect_player(delta):
		set_modulate(Color(0.5, 0.5, 0.5, 1))
	else:
		set_modulate(Color(1, 1, 1, 1))

func detect_player(delta):
	if $HELLO.is_colliding():
		print("HELLO")
	for ray in get_children():
		if ray is RayCast2D:
			if ray.is_colliding() and ray.get_collider() == player:
				return true
	return false


#func _draw():
	#draw_sight_cone()
#
#
#func draw_sight_cone():
	#print("draw")
	#var global_pos = global_position
	#var points = [global_pos] + raycast_points + [global_pos]
	#var color = Color(1, 1, 1, 0.3)
	#
	#draw_colored_polygon(points, color)



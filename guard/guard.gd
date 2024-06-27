extends CharacterBody2D

@onready var player = get_node("/root/@Node2D@2/StealthChar")

var player_detected = false
const angle_cone_of_vision = deg_to_rad(140.0)
const max_view_distance = 150.0
const angle_between_rays = deg_to_rad(10.0)
var original_position
const rotationSpeed = 2

func _ready():
	original_position = global_position
	generate_raycasts()
	%GuardAnim.idle_up_anim()

func generate_raycasts(): # many raycasts as cone of sight
	var ray_count = angle_cone_of_vision / angle_between_rays
	
	for i in ray_count:
		var ray = RayCast2D.new()
		var angle = angle_between_rays * (i - ray_count / 2.0)
		ray.target_position = Vector2.UP.rotated(angle) * max_view_distance # starting position face up
		ray.set_collision_mask_value(1, true)
		add_child(ray)
		ray.enabled = true
		
		var line = Line2D.new()
		line.default_color = Color(1,0,0)
		line.width = 2.0
		add_child(line)


func _physics_process(delta):
	move_and_slide()
	for ray in get_children():
		if ray is RayCast2D:
			update_line(ray)
	if %DetectBox.get_overlapping_bodies():
		print("player in area")
		detect_player(delta)
	else:
		print("player not in area")
	


func update_line(ray):
	for line in get_children():
		if line is Line2D:
			line.points = [ray.global_position, ray.to_global(ray.target_position)]


func detect_player(delta):
	for ray in get_children():
		if ray is RayCast2D and ray.is_colliding():
			if ray.get_collider() == player:
				print("player detected")
				chase_player(delta)


func chase_player(delta):
	var direction = player.global_position - global_position
	direction = direction.normalized()
	
	var angle_to = transform.x.angle_to(direction)
	rotate(sign(angle_to) * min(delta * rotationSpeed, abs(angle_to)))
	
	velocity = direction * 100
	
	#if direction.y < 0:
		## character is moving up
		#%GuardAnim.sprint_up_anim()
	#elif direction.y > 0:
		## character is moving down
		#%GuardAnim.sprint_down_anim()
	#elif direction.x < 0:
		## character is moving left
		#%GuardAnim.sprint_left_anim()
		## character is moving left
	#elif direction.x > 0:
		#%GuardAnim.sprint_right_anim()

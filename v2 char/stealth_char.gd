extends CharacterBody2D

const BASE_SPEED := 5000
const SPRINT_MULTIPLIER := 2.0
const ALERTBOX_RADIUS := 10.0
const ALERTBOX_MULTIPLER := 4.0
var last_direction := 0 
# to decide idle animation, 0 1 2 3 correspond to up down left right 
var health := 100.0
var item_has_charge := true

signal health_depleted

func _ready():
	Global.player = self
	Global.visual_box = %VisualBox
	%ItemTimer.start()
	%ItemTimer.set_paused(true)
	$HealthBar.visible = false
	$ItemCharge.visible = false

func _physics_process(delta):
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	# map wasd to character movement
	var speed := BASE_SPEED
	var is_sprinting := Input.is_action_pressed("sprint_active")
	# detect if shift key is held down
	if is_sprinting:
		speed *= SPRINT_MULTIPLIER
		
	velocity = direction * speed * delta
	
	if direction.y < 0:
		# character is moving up
		last_direction = 0;
		if is_sprinting:
			%StealthCharAnim.sprint_up_anim()
			%AlertBox/CollisionShape2D.shape.set_radius(ALERTBOX_RADIUS * ALERTBOX_MULTIPLER)
		else:
			%StealthCharAnim.walk_up_anim()
			%AlertBox/CollisionShape2D.shape.set_radius(ALERTBOX_RADIUS)
	elif direction.y > 0:
		# character is moving down
		last_direction = 1;
		if is_sprinting:
			%StealthCharAnim.sprint_down_anim()
			%AlertBox/CollisionShape2D.shape.set_radius(ALERTBOX_RADIUS * ALERTBOX_MULTIPLER)
		else:
			%StealthCharAnim.walk_down_anim()
			%AlertBox/CollisionShape2D.shape.set_radius(ALERTBOX_RADIUS)
	elif direction.x < 0:
		# character is moving left
		last_direction = 2;
		if is_sprinting:
			%StealthCharAnim.sprint_left_anim()
			%AlertBox/CollisionShape2D.shape.set_radius(ALERTBOX_RADIUS * ALERTBOX_MULTIPLER)
		else:
			%StealthCharAnim.walk_left_anim()
			%AlertBox/CollisionShape2D.shape.set_radius(ALERTBOX_RADIUS)
	elif direction.x > 0:
		# character is moving right
		last_direction = 3;
		if is_sprinting:
			%StealthCharAnim.sprint_right_anim()
			%AlertBox/CollisionShape2D.shape.set_radius(ALERTBOX_RADIUS * ALERTBOX_MULTIPLER)
		else:
			%StealthCharAnim.walk_right_anim()
			%AlertBox/CollisionShape2D.shape.set_radius(ALERTBOX_RADIUS)
	else:
		%AlertBox/CollisionShape2D.shape.set_radius(0)
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
	$ItemCharge.text = str(Global.gloves_unlock_left)
	if Input.is_action_just_pressed("use_item") and Global.gloves_equipped:
		$ItemCharge.visible = true
		$ChargeTimer.start()
	
	#if item_has_charge:
		#if Input.is_action_pressed("use_item"):
			#set_collision_mask_value(1, false)
			#%ItemTimer.set_paused(false)
		#else:
			#set_collision_mask_value(1, true)
			#%ItemTimer.set_paused(true)
	#else:
		#set_collision_mask_value(1, true)


func take_damage(dmg):
	print("damage")
	health -= dmg
	$HealthBar.value = health
	$HealthBar.visible = true
	$HPTimer.start()
	if health <= 0:
		print("death")
		health_depleted.emit()


func _on_item_timer_timeout():
	item_has_charge = false
	print("no charge")


func _on_hp_timer_timeout():
	$HealthBar.visible = false


func _on_charge_timer_timeout():
	$ItemCharge.visible = false

extends CharacterBody3D

# Movement settings
var speed = 5.0
var mouse_sensitivity = 0.002

var interact_distance = 3.0  # How far can player reach?
var current_interactable = null  # What are we looking at?


# Get camera reference
@onready var camera = $Camera3D
@onready var pointer: Label = get_node("../UserInterface/Pointer")

func _ready():
	# Capture mouse so it doesn't leave the window
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta):
	# Get input from WASD or Arrow keys
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	# Calculate movement direction based on where camera is facing
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	# Move the player
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		# Smoothly stop when no input
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
	
	# Apply movement
	move_and_slide()
	
	check_interaction()

func _input(event):
	# Mouse look controls
	if event is InputEventMouseMotion:
		# Rotate player left/right
		rotate_y(-event.relative.x * mouse_sensitivity)
		
		# Rotate camera up/down
		camera.rotate_x(-event.relative.y * mouse_sensitivity)
		
		# Clamp camera so you can't look too far up/down
		camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2)
	
	if event.is_action_pressed("ui_interact"):
		if current_interactable:
			current_interactable.interact()

func _unhandled_input(event):
	# Press ESC to free mouse cursor
	if event.is_action_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			
func check_interaction():
#	create raycast form camera
	var space_state = get_world_3d().direct_space_state
	# Start raycast 1 meter in front of camera (outside player collision!)
	var ray_origin = camera.global_position + (-camera.global_transform.basis.z * 1.0)
	var ray_end = ray_origin + (-camera.global_transform.basis.z * interact_distance)
	
	var query = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
	var result = space_state.intersect_ray(query)
	query.exclude = [self]
	
	if result:
		var hit_object = result.collider
		if hit_object.has_method("interact"):
			update_pointer(hit_object.name)
			current_interactable = hit_object
		else:
			pointer.update_label("")
			current_interactable = null
	else:
		pointer.update_label("")
		current_interactable = null
		
func update_pointer(name):
	match name:
		"Entrance_Door_Static", "Kitchen_Door_Static":
			pointer.update_label("Enter")
		"Bread_Container":
			pointer.update_label("Burger Bun")
		"Stove_1_Button_Static", "Stove_2_Button_Static":
			pointer.update_label("Start Stove")
		"Refrigerator_Door_Top_Static":
			pointer.update_label("Open")
		"Burger_Meat_Raw_Static":
			pointer.update_label("Burger Patty")
		"Spatula_Static", "Plate_Static":
			pointer.update_label("Pick Up")
		"Place_Mat_Static":
			pointer.update_label("Placemat")
		_:
			pointer.update_label("")
			
	

extends CharacterBody3D

# Movement settings
var speed = 5.0
var mouse_sensitivity = 0.002

var interact_distance = 3.0  # How far can player reach?
var current_interactable = null  # What are we looking at?

# Get camera reference
@onready var camera = $Camera3D
@onready var pointer: Label = get_node("../UserInterface/Pointer")
@onready var interaction = $InteractionComponent

func _ready():
	# Capture mouse so it doesn't leave the window
	interaction.interaction_available.connect(_on_interaction_available)
	interaction.interaction_unavailable.connect(_on_interaction_unavailable)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _on_interaction_available(interactable):
	print("Can interact with: ", interactable.name)

func _on_interaction_unavailable():
	print("No interactable nearby")
	
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
	
func _input(event):
	# Mouse look controls
	if event is InputEventMouseMotion:
		# Rotate player left/right
		rotate_y(-event.relative.x * mouse_sensitivity)
		
		# Rotate camera up/down
		camera.rotate_x(-event.relative.y * mouse_sensitivity)
		
		# Clamp camera so you can't look too far up/down
		camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2)
	
func _unhandled_input(event):
	# Press ESC to free mouse cursor
	if event.is_action_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			

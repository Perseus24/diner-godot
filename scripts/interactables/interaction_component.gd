# interaction_component.gd
# Attach this to your player (or any character that needs to interact)

extends Node3D
class_name InteractionComponent

signal interaction_available(interactable)
signal interaction_unavailable

@export var interact_distance: float = 3.0
@export var interaction_key: String = "ui_interact"  # Default E key
@export var debug_draw: bool = false

var current_interactable: Interactable = null
var owner_character: CharacterBody3D

@onready var ray_cast: RayCast3D = null

func _ready():
	owner_character = get_parent() as CharacterBody3D
	# Setup raycast if it doesn't exist
	if !ray_cast:
		var camera = owner_character.get_node_or_null("Camera3D")
		if camera:
			ray_cast = camera.get_node_or_null("RayCast3D")
			if !ray_cast:
				ray_cast = RayCast3D.new()
				camera.add_child(ray_cast)
	
	ray_cast.enabled = true
	ray_cast.target_position = Vector3(0, 0, -interact_distance)
	ray_cast.collision_mask = 2  # Layer 2 for interactables
	
	
	print("[Interaction] Raycast setup complete")

func _physics_process(delta):
	check_for_interactable()
	
func _input(event):
	if event.is_action_pressed(interaction_key):
		attempt_interact()

func check_for_interactable():
	ray_cast.force_raycast_update()
	var previous_interactable = current_interactable
	
	if ray_cast.is_colliding():
		var collider = ray_cast.get_collider()
		# Check if collider or its parent is interactable
		var interactable = find_interactable_in_hierarchy(collider)
		if interactable and interactable.can_be_interacted():
			current_interactable = interactable
			
			# Emit signal if this is a new interactable
			if previous_interactable != current_interactable:
				interaction_available.emit(current_interactable)
		else:
			clear_interactable(previous_interactable)
	else:
		clear_interactable(previous_interactable)

func find_interactable_in_hierarchy(node):
	# Check the node itself first
	if node is Interactable:
		return node
	
	# Check children (and their children recursively)
	for child in node.get_children():
		if child is Interactable:
			return child
		# Check grandchildren
		var found = find_interactable_in_hierarchy(child)
		if found:
			return found
	
	# Check parents
	var current = node.get_parent()
	while current:
		if current is Interactable:
			return current
		current = current.get_parent()
	
	return null

func clear_interactable(previous):
	if current_interactable != null:
		current_interactable = null
		if previous != null:
			interaction_unavailable.emit()

func attempt_interact():
	if current_interactable:
		print("[Interaction] Interacting with ", current_interactable.name)
		current_interactable.interact(owner_character)
		return true
	return false

func get_interaction_text() -> String:
	if current_interactable:
		return current_interactable.get_interaction_text()
	return ""

func has_interactable() -> bool:
	return current_interactable != null

func draw_debug_line():
	
	pass

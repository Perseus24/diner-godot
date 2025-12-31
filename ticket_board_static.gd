extends Interactable
@onready var ticket_scene = preload("res://ticket.tscn")

func _ready() -> void:
	update_interaction_text()
	pass 

func interact(interactor = null):
	var mouse_pos = get_viewport().get_mouse_position()
	
	var player = get_tree().get_first_node_in_group("player")
	
	var camera = player.get_node("Camera3D")
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * 100
	
	var space = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to)
	var result = space.intersect_ray(query)
	
	# get the ticket node from the camera
	var ticket_item = camera.get_node_or_null("Ticket")
	
	if ticket_item:
		ticket_item.reparent(self)
		for child in ticket_item.get_children():
			if child is StaticBody3D:
				child.get_node("CollisionShape3D").disabled = false
		
		ticket_item.global_position = result.position + Vector3(0.03, 0, 0)
		ticket_item.global_rotation.y = deg_to_rad(90)
		ticket_item.global_rotation.x = deg_to_rad(1)
		
		#ticket_item.queue_free()
	print_tree_pretty()
	
	super.interact(interactor)

func handle_ticket_picked_up(ticket):
	print("ticket picked up")
	ticket.queue_free()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func update_interaction_text():
	interaction_text = "Place Ticket"

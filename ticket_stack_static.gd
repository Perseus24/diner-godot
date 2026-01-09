extends Interactable

@onready var ticket_scene = preload("res://ticket.tscn")

func _ready() -> void:
	update_interaction_text()
	pass 


func _process(delta: float) -> void:
	pass
	
func interact(interactor=null):
	print("stack the ticket")
	var player = get_tree().get_first_node_in_group("player")
	var camera = player.get_node("Camera3D")
	
	var ticket_item = camera.get_node_or_null("Ticket")
	if ticket_item:
		var marker = get_parent().get_node("Marker3D")
		ticket_item.reparent(self)
		
		ticket_item.global_position = marker.global_position
		ticket_item.global_rotation.x = deg_to_rad(-90)
		ticket_item.global_rotation.y = deg_to_rad(180)
		
	super.interact(interactor)
	
func update_interaction_text():
	interaction_text = "Stack Ticket"

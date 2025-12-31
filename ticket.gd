extends Interactable

const PlayerItems = preload("res://scripts/item_manager.gd")
@onready var ticket_scene = preload("res://ticket.tscn")

signal ticket_picked_up(ticket)

func _ready() -> void:
	update_interaction_text()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func interact(interactor = null):
	print("Interact called, emitting signal")
	PlayerItems.attach_node_to_player(self.get_parent(), Vector3(0.996, -0.48, -1.252), 2, -11.5, 0, false)
	
	var board = get_parent().get_parent()
	#ticket_picked_up.connect(board.handle_ticket_picked_up)
	#ticket_picked_up.emit(self.get_parent())
	
	super.interact(interactor)
	
func update_interaction_text():
	interaction_text = "Pick up"

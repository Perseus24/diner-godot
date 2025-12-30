extends Interactable

const PlayerItems = preload("res://scripts/item_manager.gd")
@onready var patty_scene = preload("res://burger_patty_raw.tscn")

func _ready() -> void:
	update_interaction_text()
	pass 


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func interact(interactor=null):
	PlayerItems.attach_item_to_player(patty_scene, Vector3(0.3, -0.3, -0.6), 'Raw_meat')
	visible = false
	super.interact(interactor)
	
func update_interaction_text():
	interaction_text = "Burger Patty"

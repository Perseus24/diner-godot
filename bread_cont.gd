extends Interactable

const PlayerItems = preload("res://scripts/item_manager.gd")
@onready var bun_scene = preload("res://burger_bun.tscn")


func _ready() -> void:
	update_interaction_text()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func interact(interactor = null):
	PlayerItems.attach_item_to_player(bun_scene, Vector3(0.3, -0.3, -0.6), 'Sketchfab_Scene')
	super.interact(interactor)
	
	
func update_interaction_text():
	interaction_text = "Burger Bun"

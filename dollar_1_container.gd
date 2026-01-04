extends Interactable

const PlayerItems = preload("res://scripts/item_manager.gd")
@onready var dollar_scene = preload("res://scenes/currency/dollar_1.tscn")
func _ready() -> void:
	update_interaction_text()
	pass 

func interact(interactor = null):
	print("getting 1 dollar")
	var cash_register_node = get_tree().get_first_node_in_group("cash_register")
	var marker = cash_register_node.get_node("Change_Position").get_node("marker_1_dollar")
	
	var dollar = dollar_scene.instantiate()
	cash_register_node.get_node("Change_Position").add_child(dollar) 
	# position the dollar on its marker
	dollar.rotation = Vector3.ZERO
	dollar.scale = Vector3(0.002, 0.002, 0.002)
	dollar.position = marker.position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func update_interaction_text():
	interaction_text = "Get 1 Dollar"

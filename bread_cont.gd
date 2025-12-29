extends StaticBody3D

const PlayerItems = preload("res://utility/item_manager.gd")
@onready var bun_scene = preload("res://burger_bun.tscn")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func interact():
	PlayerItems.attach_item_to_player(bun_scene, Vector3(0.3, -0.3, -0.6), 'Sketchfab_Scene')
	

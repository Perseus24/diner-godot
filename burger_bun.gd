extends StaticBody3D

const PlayerItems = preload("res://utility/item_manager.gd")
@onready var bun_scene = preload("res://burger_bun.tscn")

var is_cooked = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func cook():
	await get_tree().create_timer(6.0).timeout
	$"../Label3D".visible = true
	is_cooked = true
	
func interact():
	var is_burger_bun_cooked = $"../Label3D".visible #check if the bun is cooked
	if is_burger_bun_cooked:
		PlayerItems.attach_item_to_player(bun_scene, Vector3(0.3, -0.3, -0.6), 'Sketchfab_Scene')
		var display_bun = get_parent().get_parent().get_node_or_null('Sketchfab_Scene')
		if display_bun:
			print("thers a display bun")
			display_bun.queue_free()
		get_parent().queue_free()
		

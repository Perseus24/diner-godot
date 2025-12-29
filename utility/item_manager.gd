extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

static func attach_item_to_player(item_scene: PackedScene, offset: Vector3, node_name: String):
	var item = item_scene.instantiate()
	var tree = Engine.get_main_loop() as SceneTree
	tree.current_scene.add_child(item)
	
	var player = tree.get_first_node_in_group("player")
	var camera = player.get_node('Camera3D')
	
	# make the item a child of the camera so it always follow
	var mesh = item.get_node(node_name)
	mesh.reparent(camera)
	
	mesh.position = offset
	
	item.queue_free()

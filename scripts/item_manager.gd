extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

static func attach_item_to_player(item_scene: PackedScene, offset: Vector3, node_name: String,):
	var item = item_scene.instantiate()
	var tree = Engine.get_main_loop() as SceneTree
	tree.current_scene.add_child(item)
	
	var player = tree.get_first_node_in_group("player")
	var camera = player.get_node('Camera3D')
	# make the item a child of the camera so it always follow
	var mesh = item.get_node(node_name)
	if mesh:
			
		mesh.reparent(camera)
		mesh.position = offset
		
	item.queue_free()
	
# if its a node, just reparent it. dont instantiate
# currently, this is being used by the ticket scene
static func attach_node_to_player(node: Node3D,  offset: Vector3, rotation_y: int = 0, rotation_x: int = 0, rotation_z: int = 0, is_instantiate = true):
	var tree = Engine.get_main_loop() as SceneTree
	var player = tree.get_first_node_in_group("player")
	var camera = player.get_node('Camera3D')
	
	print("node from attach player")
	print(node)
	if node:
		for child in node.get_children():
			if child is StaticBody3D:
				child.get_node("CollisionShape3D").disabled = true
		
		if is_instantiate:
			camera.add_child(node)
		else:
			node.reparent(camera)
		camera.print_tree()
		node.position = offset
		if rotation_x != 0:
			node.rotation.y = deg_to_rad(rotation_y)
			node.rotation.x = deg_to_rad(rotation_x)
			node.rotation.z = deg_to_rad(rotation_z)
			

extends StaticBody3D

@onready var plate_scene = preload("res://plate.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func interact():
	var plate = plate_scene.instantiate()
	get_tree().current_scene.add_child(plate)
	
	var player = get_tree().get_first_node_in_group("player")
	var camera = player.get_node('Camera3D')
	
	# make the plate a child of the camera so it always follow
	var mesh = plate.get_node("Plate_Medium")
	mesh.reparent(camera)
	
	mesh.position = Vector3(0.3, -0.3, -0.6)
	
	plate.queue_free()
	visible = false

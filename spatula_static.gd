extends StaticBody3D

@onready var spatula_scene = preload("res://spatula.tscn")
var is_picked_up = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func interact():
	var player = get_tree().get_first_node_in_group("player")
	var camera = player.get_node('Camera3D')
	
	if is_picked_up:
		var mesh = camera.get_node("Cube_223")
		mesh.queue_free()
		
		$"../Cube_223".visible = true
		is_picked_up = false
	else:	
		is_picked_up = true
		var spatula = spatula_scene.instantiate()
		get_tree().current_scene.add_child(spatula)
		
		# make the spatula a child of the camera so it always follow
		var mesh = spatula.get_node("Cube_223")
		mesh.reparent(camera)
		
		mesh.position = Vector3(0.3, -0.3, -0.6)
		mesh.rotation_degrees = Vector3(0,180,0)
		
		spatula.queue_free()
		$"../Cube_223".visible = false
		
		visible = false

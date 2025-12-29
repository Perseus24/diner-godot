extends StaticBody3D
@onready var bun_scene = preload("res://burger_bun.tscn")
@onready var patty_scene = preload("res://burger_patty_raw.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func interact():
	print("putting down")
	var player = get_tree().get_first_node_in_group("player")
	var camera = player.get_node("Camera3D")
	
	var bun_in_hand = camera.get_node_or_null("Sketchfab_Scene")
	var raw_patty_in_hand = camera.get_node_or_null("Raw_meat")
	
	if bun_in_hand:
		# duplicate the bun
		var bun = bun_scene.instantiate()
		var second_bun = bun_in_hand.duplicate()
		#bun.reparent(self, true)w
		get_tree().current_scene.add_child(second_bun)
		get_tree().current_scene.add_child(bun)
		
		bun.global_position = global_position + Vector3(0,0.2,-0.4)
		second_bun.global_position = global_position + Vector3(0,0.2,-0.7)
		
		bun.get_node("StaticBody3D").cook()
		bun_in_hand.queue_free()
	
	if raw_patty_in_hand:
		var patty = patty_scene.instantiate()
		get_tree().current_scene.add_child(patty)

		patty.global_position = global_position + Vector3(0,0.2,-0.4)
		
		patty.get_node("StaticBody3D").cook()
		raw_patty_in_hand.queue_free()
	
	
	

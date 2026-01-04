extends Interactable

var is_interacting = false

func _ready() -> void:
	update_interaction_text()
	pass 

func interact(interactor=null):
	is_interacting = true
	var to_player = (interactor.global_position - global_position).normalized()
	var forward = global_transform.basis.z # forward direction of the cash register
	
	if forward.dot(to_player) < 0.2: #if player is behind the counter, dont interact
		return
	
	var player = get_tree().get_first_node_in_group("player")
	var camera = player.get_node("Camera3D")
	
	player.movement_restricted = true #temporarily restrict the player's mvoement
	camera.position.z = -0.2
	camera.rotation_degrees.x = -40
	
	var tween = create_tween()
	tween.tween_property(camera, "fov", 40.0, 0.3)
	
	# temporarily disable this static body so that the bills can be interacted
	get_node("CollisionShape3D").disabled = true
	super.interact(interactor)
	
	 
func _input(event):
	if is_interacting:
		if event.is_action_pressed("ui_cancel"):
			exit_register()
			get_viewport().set_input_as_handled()
		
# reset the camera
func exit_register():
	is_interacting = false
	var player = get_tree().get_first_node_in_group("player")
	var camera = player.get_node("Camera3D")
	
	camera.position.z = 0
	camera.rotation_degrees.x = 0
	
	var tween = create_tween()
	tween.tween_property(camera, "fov", 75.0, 0.3)
	
	player.movement_restricted = false
	get_node("CollisionShape3D").disabled = false
	
	
func _process(delta: float) -> void:
	pass

func update_interaction_text():
	interaction_text = "Use"

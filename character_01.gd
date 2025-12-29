extends CharacterBody3D

@onready var path_follow = $"../Path3D/PathFollow3D"
@onready var camera = $Camera3D  # NPC's "eyes"

var walking_speed = 2.5
var moving = true

var interact_distance = 1.0
var current_interactable = null
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	$"Male_Casual/AnimationPlayer".play("HumanArmature|Man_Walk")
	$"Male_Casual/AnimationPlayer".animation_finished.connect(_on_anim_finished)
	pass # Replace with function body.
	

func _on_anim_finished(anim_name):
	if anim_name == "HumanArmature|Man_Walk":
		$"Male_Casual/AnimationPlayer".play(anim_name)
		
func _physics_process(delta):
	if moving:
		# Check if finished
		if path_follow.progress_ratio >= 1.0:
			print("Finished path!")
			moving = false
			$"Male_Casual/AnimationPlayer".stop()
			return
		
		var old_position = global_position
		
		path_follow.progress += walking_speed * delta
		global_position = path_follow.global_position
		
		check_interaction()
		
		# Face movement direction
		var direction = (global_position - old_position).normalized()
		if direction.length() > 0.01:
			look_at(global_position + direction, Vector3.UP)

func check_interaction():
	var space_state = get_world_3d().direct_space_state
	var ray_origin = camera.global_position + (-camera.global_transform.basis.z * 1.0)
	var ray_end = ray_origin + (-camera.global_transform.basis.z * interact_distance)
	
	var query = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
	query.exclude = [self]
	var result = space_state.intersect_ray(query)
	
	if result and result.collider.has_method("interact"):
		current_interactable = result.collider
		# Auto-interact when NPC reaches door
		current_interactable.interact()
	else:
		current_interactable = null
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	pass

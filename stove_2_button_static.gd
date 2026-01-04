extends Interactable
@onready var bun_scene = preload("res://burger_bun.tscn")
@onready var patty_scene = preload("res://burger_patty_raw.tscn")

var is_sizzling_bgm_played = false

func _ready() -> void:
	pass 


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	update_interaction_text()
	
	#await $AudioStreamPlayer3D.finished
	#if is_sizzling_bgm_played:
		#$AudioStreamPlayer3D.play(4)
	pass
	
func interact(interactor=null):
	var player = get_tree().get_first_node_in_group("player")
	var camera = player.get_node("Camera3D")
	
	var bun_in_hand = camera.get_node_or_null("Sketchfab_Scene")
	var raw_patty_in_hand = camera.get_node_or_null("Raw_meat")
	
	if bun_in_hand:
		# duplicate the bun
		var bun = bun_scene.instantiate()
		var second_bun = bun_in_hand.duplicate()
		#bun.reparent(self, true)w
		add_child(second_bun)
		add_child(bun)
		
		bun.global_position = global_position + Vector3(0,0.2,-0.4)
		second_bun.global_position = global_position + Vector3(0,0.2,-0.7)
		
		bun.get_node("StaticBody3D").cook()
		bun_in_hand.queue_free()
		is_sizzling_bgm_played = true
		$AudioStreamPlayer3D.play()
		
	if raw_patty_in_hand:
		var patty = patty_scene.instantiate()
		add_child(patty)

		patty.global_position = global_position + Vector3(0,0.2,-0.4)
		
		patty.get_node("StaticBody3D").cook()
		raw_patty_in_hand.queue_free()
		is_sizzling_bgm_played = true
		$AudioStreamPlayer3D.play()
		
	super.interact(interactor)

func item_picked_up(node = null):
	for child in get_children():
		print(child)
		if child is CollisionShape3D or child is AudioStreamPlayer3D:
			pass
		child.queue_free() #delete all items from the stove
		
	#stop the sizzling bgm
	$AudioStreamPlayer3D.stop()
	
func update_interaction_text():
	interaction_text = "Start Stove"
	
	

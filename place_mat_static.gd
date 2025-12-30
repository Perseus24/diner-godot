extends Interactable

@onready var plate_scene = preload("res://plate.tscn")
@onready var burger_plain_scene = preload("res://burger_plain.tscn")
var is_plate_placed = false
var is_patty_placed = false
var is_bun_placed = false

func _ready() -> void:
	update_interaction_text()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func interact(interactor=null):
	var player = get_tree().get_first_node_in_group("player")
	var camera = player.get_node('Camera3D')
	
	var plate = camera.get_node_or_null("Plate_Medium")
	var bun = camera.get_node_or_null("Sketchfab_Scene")
	var patty = camera.get_node_or_null("Roast_meat")
	
	if !is_plate_placed && plate:
		# put the plate scene
		plate.reparent(self, true)
		plate.position = Vector3(0, 0.05, 0)
		plate.rotation = Vector3.ZERO
		is_plate_placed = true
		
	if is_plate_placed && bun:
		is_bun_placed = true
		bun.reparent(self, true)
		bun.position = Vector3(0, 0.07, 0)
		bun.rotation = Vector3.ZERO
		
	if is_plate_placed && patty:
		is_patty_placed = true
		patty.reparent(self, true)
		patty.position = Vector3(0, 0.07, 0)
		patty.rotation = Vector3.ZERO
		
	make_burger()
	super.interact(interactor)
	
		
func make_burger():
	if !is_patty_placed || !is_bun_placed || !is_plate_placed:
		return
	
	var burger_plain = burger_plain_scene.instantiate()
	add_child(burger_plain)
	
	burger_plain.position = Vector3(0, 0.05, 0)
	#remove other ingredients
	get_node("Sketchfab_Scene").queue_free()
	get_node("Roast_meat").queue_free()
	
func update_interaction_text():
	interaction_text = "Placemat"
	
	

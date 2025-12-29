extends StaticBody3D
const PlayerItems = preload("res://utility/item_manager.gd")
@onready var patty_scene = preload("res://burger_patty_raw.tscn")

var is_cooked_half = false
var is_cooked_full = false

var is_cooking = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func cook():
	is_cooking = true
	
	await get_tree().create_timer(6.0).timeout
	$"../Label3D".visible = true
	is_cooked_half = true
	
	
func interact(): #flip
	var player = get_tree().get_first_node_in_group("player")
	var camera = player.get_node("Camera3D")
	var spatula = camera.get_node_or_null("Cube_223")
	
	if !spatula:
		return 
		
	if !is_cooked_half:
		return
		
	if spatula && is_cooked_full:
		get_patty()
		
	$"../Raw_meat".visible = false
	$"../Roast_meat".visible = true
	$"../Label3D".visible = false
	
	await get_tree().create_timer(6.0).timeout
	is_cooked_full = true
	$"../Label3D".visible = true
	$"../Label3D".text = "Cooked"
	
func get_patty():
	var player = get_tree().get_first_node_in_group("player")
	var camera = player.get_node("Camera3D")
	
	PlayerItems.attach_item_to_player(patty_scene, Vector3(0.3, -0.3, -0.6), 'Roast_meat')
	var patty = camera.get_node("Roast_meat")
	patty.visible = true
	
	camera.get_node("Cube_223").queue_free()
	var spatula = get_tree().get_first_node_in_group("spatula")
	if spatula:
		print("hello?")
		spatula.get_node_or_null("Cube_223").visible = true
	get_parent().queue_free()
	
	
	

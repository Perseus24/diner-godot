extends CharacterBody3D
class_name NPCBase
enum State {
	SPAWNED,
	WALKING_TO_ENTRANCE,
	OPENING_ENTRANCE_DOOR,
	WAITING_FOR_DOOR,
	LOOKING_FOR_CHAIR,
	WALKING_TO_CHAIR,
	SITTING_DOWN,
	READING_MENU,
	WAITING_FOR_WAITER,
	PLACING_ORDER,
	WAITING_FOR_FOOD,
	EATING,
	IDLE,
	WALKING_TO_COUNTER,
	WALKING_TO_EXIT,
	OPENING_EXIT_DOOR,
	WALKING_OUTSIDE,
	LEAVING,
	RANDOM_EVENTS
}
const PlayerItems = preload("res://scripts/item_manager.gd")

@onready var ticket_scene = preload("res://ticket.tscn")
@onready var plate_scene = preload("res://plate.tscn")

# SIGNALS

signal state_changed(old_state, new_state)
signal interaction_available(interactable)
signal reached_destination
signal order_placed(order_data)
signal finished_eating
signal leaving

# EXPORT

@export_group("Movement")
@export var base_walking_speed: float = 2.0
@export var running_speed: float = 4.0

@export_group("Interaction")
@export var interact_distance: float = 1.5
@export var auto_interact: bool = true 

@export_group("Timing")
@export var menu_reading_time: float = 5.0
@export var eating_duration: float = 15.0
@export var patience_level: int = 5 # 1-10 scale

var current_state = State.IDLE
var previous_state = State.IDLE

var walking_speed: float = 2.0
var current_path_follow: PathFollow3D = null
var current_target_position: Vector3 = Vector3.ZERO
var is_moving: bool = false

var current_interactable = null
var nearby_interactables: Array = []

var character_first_name: String = "Unknown Customer"
var character_last_name: String = "Unknown Customer"
var backstory: String = ""
var personality: Dictionary = {}
var favorite_food: String = ""
var order_data: Dictionary = {}

var chosen_seat_to = null
var is_sitting = false
var has_placed_order = false
var is_waiting_for_order = false
var is_eating = false
var is_walking_to_counter = false

@onready var camera: Camera3D = $Camera3D
@onready var animation_player: AnimationPlayer = $Male_Casual/AnimationPlayer
@onready var interaction_ray: RayCast3D 

func _ready() -> void:
	print("ready called npc base")
	load_story()
	
	setup_interaction_system()
	
	call_deferred("start_routine")
	
	print("[NPC] ", character_first_name, " has entered the scene")

func load_story(): #override
	pass
	
func generate_order(): #override
	pass
	
func setup_interaction_system():
	# setup raycast
	if !interaction_ray:
		interaction_ray = RayCast3D.new()
		add_child(interaction_ray)
		
	interaction_ray.enabled = true
	interaction_ray.target_position = Vector3(0,0, -interact_distance)
	interaction_ray.collision_mask = 2 # interact only obj with layer 2
	
func start_routine():
	print("starting routine")
	change_state(State.WALKING_TO_ENTRANCE)
	
func _physics_process(delta: float) -> void:
	match current_state:
		State.IDLE:
			process_idle()
		
		State.WALKING_TO_ENTRANCE:
			process_walking_to_entrance(delta)
			
		State.OPENING_ENTRANCE_DOOR:
			process_opening_door()
			
		State.WAITING_FOR_DOOR:
			pass
			#
		State.LOOKING_FOR_CHAIR:
			process_looking_for_chair()
			#
		State.WALKING_TO_CHAIR:
			process_walking(delta)
			#
		State.SITTING_DOWN:
			process_sitting_down()
			#
		State.READING_MENU:
			process_reading_menu()
			#
		State.WAITING_FOR_WAITER:
			process_waiting_for_waiter()
		#
		State.PLACING_ORDER:
			process_placing_order()
			#
		State.WAITING_FOR_FOOD:
			process_waiting_for_food()
		#
		State.EATING:
			process_eating()
			#
		State.WALKING_TO_COUNTER:
			process_walking(delta)
		#
		#State.WALKING_TO_EXIT:
			#process_walking_to_exit(delta)
		#
		#State.OPENING_EXIT_DOOR:
			#process_opening_exit_door(delta)
		#
		#State.WALKING_OUTSIDE:
			#process_walking_outside(delta)
#
		#State.LEAVING:
			#process_leaving(delta)
			#
		#State.RANDOM_EVENTS:
			#process_random_events(delta)
	#check_interaction()
	
func process_idle():
	pass
	
func change_state(new_state):
	if current_state == new_state:
		return
		
	previous_state = current_state
	current_state = new_state
	
	state_changed.emit(previous_state, current_state)
	
func follow_current_path(delta):
	if !current_path_follow:
		return
	# Move progress forward
	current_path_follow.progress += walking_speed * delta
	# Update character position
	global_position = current_path_follow.global_position
	
	# Face movement direction
	var forward = current_path_follow.transform.basis.z  
	forward.y = 0  # Flatten
	forward = forward.normalized()
	if forward.length() > 0.01:
		var target_pos = global_position + forward
		look_at(target_pos, Vector3.UP)
		rotation.x = 0
		rotation.z = 0
		
func process_walking_to_entrance(delta):
	if !current_path_follow: #no path follwiing
		var entrance_path = get_tree().get_nodes_in_group("entrance_path")
		if entrance_path.size() > 0:
			var random_index = randi() % entrance_path.size()
			var path = entrance_path[random_index]
			current_path_follow = path.get_node("PathFollow3D")
			current_path_follow.progress = 0
			
			animation_player.play("HumanArmature|Man_Walk")
			print("[NPC] ", character_first_name, " heading to entrance")
	
	if current_path_follow:
		follow_current_path(delta)
		if current_path_follow.progress_ratio >= 1:
			print("[NPC] ", character_first_name, " reached entrance")
			animation_player.stop()
			current_path_follow = null
			change_state(State.OPENING_ENTRANCE_DOOR)
			
func process_opening_door():
	# Look for door
	if !current_interactable:
		var doors = get_tree().get_nodes_in_group("entrance_door")
		if doors.size() > 0:
			current_interactable = doors[0]
	
	if current_interactable and current_interactable.has_method("interact"):
		current_interactable.interact()
		print("[NPC] ", character_first_name, " opened the door")
		# Wait for door animation
		change_state(State.WAITING_FOR_DOOR)
		
		await get_tree().create_timer(1.0).timeout
		
		current_interactable = null
		current_path_follow = null
		
		change_state(State.LOOKING_FOR_CHAIR)
		
func process_looking_for_chair():
	# Get all chairs
	var seats = get_tree().get_nodes_in_group("seat")
	var available_seats = []
	
	# Filter for empty seats
	for chair in seats:
		if chair.has_method("is_occupied") and !chair.is_occupied():
			available_seats.append(chair)
	if available_seats.size() > 0:
		var chosen_seat = available_seats[randi() % available_seats.size()]
		
		# Find path to this chair
		var seat_path = find_path_to_chair(chosen_seat)
		if seat_path:
			current_path_follow = seat_path.get_node("PathFollow3D")
			current_path_follow.progress = 0.0
			print("[NPC] ", character_first_name, " found a seat")
			
			chosen_seat_to = chosen_seat
			change_state(State.WALKING_TO_CHAIR)
	else:
		# No chairs available - wait or leave
		print("[NPC] ", character_first_name, " can't find a seat!")
		await get_tree().create_timer(5.0).timeout
		# Try again or leave frustrated
		change_state(State.WALKING_TO_EXIT)
		
func process_walking(delta):
	if current_path_follow:
		print("process walking")
		animation_player.play("HumanArmature|Man_Walk")
		follow_current_path(delta)
		print(current_path_follow.progress_ratio)
		if current_path_follow.progress_ratio >= 1:
			animation_player.stop()
			current_path_follow = null
			
			match current_state:
				State.WALKING_TO_CHAIR:
					change_state(State.SITTING_DOWN)
				State.WALKING_TO_COUNTER:
					print("reached the counter")
		
func process_sitting_down():
	
	var target_seat = chosen_seat_to
	var sit_marker = target_seat.get_sit_position()
	
	global_position = sit_marker
	global_rotation.y = deg_to_rad(90)
	
	animation_player.play("HumanArmature|Man_Sitting")
	is_sitting = true
	
	# Get animation length
	await animation_player.animation_finished
	if is_sitting:
		animation_player.seek(0.6, true)
		
	change_state(State.READING_MENU)
	
func process_reading_menu():
	print("[NPC] ", character_first_name, " reading the menu")
	await get_tree().create_timer(menu_reading_time).timeout
	var label_ready_to_order = chosen_seat_to.get_node_or_null("Label3D")
	if label_ready_to_order:
		label_ready_to_order.visible = true
	change_state(State.WAITING_FOR_WAITER)
	
func process_waiting_for_waiter():
	print("[NPC] ", character_first_name, " is waiting for waiter")
	
func process_placing_order():
	if has_placed_order:
		return
		
	has_placed_order = true
	print("[NPC] ", character_first_name, " is placing order")
	var ticket = ticket_scene.instantiate()
	
	generate_order()
	if ticket:
		var seat_position_name = chosen_seat_to.name # Seat Left
		var sofa_name = chosen_seat_to.get_parent().name # Sofa_Right
		var table_name = chosen_seat_to.get_parent().get_parent().name # Table_1
		var temp_number = sofa_name + "_" + seat_position_name
		
		#generate and attach the ticket with the order
		ticket.get_node("TableNumber").text = "Table " + str(table_name.split("_")[1]) + " Seat " + str(determine_table_number(temp_number))
		ticket.get_node("OrderItem").text = "\n".join(order_data.items)
		PlayerItems.attach_node_to_player(ticket, Vector3(0.996, -0.48, -1.252), 2, -11.5, 0)
	
	# turn off the ready for order label
	var label_ready_to_order = chosen_seat_to.get_node_or_null("Label3D")
	label_ready_to_order.visible = false
	change_state(State.WAITING_FOR_FOOD)
	
func process_waiting_for_food():
	if is_waiting_for_order:
		return
		
	is_waiting_for_order = true
	print("[NPC] ", character_first_name, " is waiting for order")
	
func process_eating():
	if is_eating:
		return
	
	is_eating = true
	await get_tree().create_timer(eating_duration).timeout #wait for the npc to eat
	is_eating = false
	
	#leave plate in the table
	var plates_in_the_table = chosen_seat_to.get_node("Plates_Position")
	var food = plates_in_the_table.get_node_or_null("Plain_Burger")
	
	if food:
		print("there is food in the table")
		
		var plate = plate_scene.instantiate()
		plates_in_the_table.add_child(plate) #leave plate
		plate.position = food.position
		
		food.queue_free()
		
	else:
		print("no food")
	# walk npc to counter after eating
	var table_name = chosen_seat_to.get_parent().get_parent().name # Table_1
	var path_name = str(table_name) + "_To_Counter"
	var path_to_counter = get_tree().get_first_node_in_group(path_name)
	
	current_path_follow = path_to_counter.get_node("PathFollow3D")
	current_path_follow.progress = 0.0
	change_state(State.WALKING_TO_COUNTER)
	
func process_walking_to_counter(delta):
	print("[NPC] ", character_first_name, " is walking to counter")
	
func find_path_to_chair(seat):
	
	if current_state == State.LOOKING_FOR_CHAIR:
		return get_tree().get_first_node_in_group("Table1_Sofa_Right_path_entrance")

func determine_table_number(position):
	match position:
		"Sofa_Left_Seat_Right":
			return 1
		"Sofa_Left_Seat_Left":
			return 2
		"Sofa_Right_Seat_Right":
			return 3
		"Sofa_Right_Seat_Left":
			return 4

func place_food_to_table():
	print("Placing food")
	is_waiting_for_order = false
	
	var order_items = order_data.items
	if order_items.size() == 1:
		var plate_position_node = chosen_seat_to.get_node("Plates_Position")
		var plate_marker = plate_position_node.get_node("Marker_Main_Plate")
		
		var camera = get_player_camera()
		var food = camera.get_node_or_null("Plain_Burger") # make this dynamic to match items with their names
		if food:
			food.reparent(plate_position_node)
			
			food.rotation = Vector3.ZERO
			food.scale = Vector3.ONE
			food.position = plate_marker.position
			
	change_state(State.EATING)




func get_player_camera():
	var player = get_tree().get_first_node_in_group("player")
	return player.get_node("Camera3D")
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

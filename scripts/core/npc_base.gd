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
	STANDING_UP,
	WALKING_TO_EXIT,
	OPENING_EXIT_DOOR,
	WALKING_OUTSIDE,
	LEAVING,
	RANDOM_EVENTS
}

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
			process_idle(delta)
		
		State.WALKING_TO_ENTRANCE:
			process_walking_to_entrance(delta)
			
		State.OPENING_ENTRANCE_DOOR:
			process_opening_door(delta)
			
		State.WAITING_FOR_DOOR:
			pass
			#
		State.LOOKING_FOR_CHAIR:
			process_looking_for_chair(delta)
			#
		State.WALKING_TO_CHAIR:
			process_walking_to_chair(delta)
			#
		State.SITTING_DOWN:
			process_sitting_down(delta)
			#
		#State.READING_MENU:
			#process_reading_menu(delta)
			#
		#State.WAITING_FOR_WAITER:
			#process_waiting_for_waiter(delta)
		#
		#State.PLACING_ORDER:
			#process_placing_order(delta)
			#
		#State.WAITING_FOR_FOOD:
			#process_waiting_for_food(delta)
		#
		#State.EATING:
			#process_eating(delta)
			#
		#State.STANDING_UP:
			#process_standing_up(delta)
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
	
func process_idle(delta):
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
			
func process_opening_door(delta):
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
		
		
func process_looking_for_chair(delta):
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
		
func process_walking_to_chair(delta):
	
	if current_path_follow:
		animation_player.play("HumanArmature|Man_Walk")
		follow_current_path(delta)
		if current_path_follow.progress_ratio >= 1:
			print("[NPC] ", character_first_name, " reached seat")
			animation_player.stop()
			current_path_follow = null
			change_state(State.SITTING_DOWN)
		
func process_sitting_down(delta):
	var target_seat = chosen_seat_to
	var sit_marker = target_seat.get_sit_position()
	
	global_position = sit_marker
	global_rotation.y = deg_to_rad(90)
	
	animation_player.play("HumanArmature|Man_Sitting")
	
func find_path_to_chair(seat):
	var seat_position_name = seat.name # Seat Left
	var sofa_name = seat.get_parent().name # Sofa_Right
	var table_name = seat.get_parent().get_parent().name # Table1
	
	if current_state == State.LOOKING_FOR_CHAIR:
		return get_tree().get_first_node_in_group("Table1_Sofa_Right_path_entrance")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

extends NPCBase

func load_story():
	print("loading story")
	character_first_name = "John"
	character_last_name = "Smith"
	
	personality = {
		"mood": "melancholic",
		"patience": 9,
		"tip_percentage": 20,
		"politeness": 10,
		"chattiness": 2,
		"appetite": "moderate",
		"impatient": "false",
		"indecisive": "false",
		"rushed": "false",
		"slow_eater": "true"
	}
	
	favorite_food = "Pasta"
	base_walking_speed = 1.5
	menu_reading_time = 1
	eating_duration = 30
	
	setup_special_behaviors()
	
func setup_special_behaviors():
	var date = Time.get_date_dict_from_system()
	if date.month == 6 and date.day == 15:
		print("[SPECIAL] Today is Sarah's birthday")

func generate_order():
	var base_order = {
		"item": "Burger",
		"special_requests": ["Double Meat"],
		"tip_percentage": 20
	}
	
	order_data = base_order
	
func _ready():
	super._ready()
	print("john smith")
	animation_player.animation_finished.connect(_on_animation_finished)

func _on_animation_finished(anim_name):
	if anim_name == "HumanArmature|Man_Walk":
		animation_player.play("HumanArmature|Man_Walk")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

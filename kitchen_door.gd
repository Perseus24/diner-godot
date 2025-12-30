extends Interactable

@export var is_open: bool = false
@export var open_duration: float = 1.0
@export var auto_close: bool = true
@export var auto_close_delay: float = 3.0


@onready var anim_player = $"../AnimationPlayer"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_interaction_text()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func interact(interactor = null):
	if is_open:
		close_door()
	else:
		open_door()
		
	super.interact(interactor)
	
func open_door():
	if is_open:
		return
	
	is_open = true
	can_interact = false
	anim_player.play("door_open")
	
	can_interact = true
	update_interaction_text()
	
		
func close_door():
	if !is_open:
		return
	
	is_open = false
	can_interact = false
	anim_player.play("door_close")
	
	can_interact = true
	update_interaction_text()
	
func update_interaction_text():
	interaction_text = "Open Door" if !is_open else "Close Door"

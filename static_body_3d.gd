extends StaticBody3D  

@onready var anim_player = $"../AnimationPlayer"
var is_open = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func interact():
	if is_open:
		anim_player.play("door_close")
		is_open = false
	else:
		anim_player.play("door_open")
		is_open = true

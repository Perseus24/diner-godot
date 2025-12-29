extends Label

# Called when the node enters the scene tree for the first time.
func _ready():
	vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

func _draw():
	var center = Vector2(size.x / 2, size.y / 2 - 20)
	draw_circle(center, 3.0, Color.WHITE)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func update_label(title):
	text = title

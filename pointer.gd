extends Label

var interaction_component: InteractionComponent

func _ready():
	vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	var player = get_tree().get_first_node_in_group("player")
	if player:
		interaction_component = player.get_node_or_null("InteractionComponent")
		


func _draw():
	var center = Vector2(size.x / 2, size.y / 2 - 20)
	draw_circle(center, 3.0, Color.WHITE)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if interaction_component:
		text = interaction_component.get_interaction_text()
	pass
	
func update_label(title):
	text = title

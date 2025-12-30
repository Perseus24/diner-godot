extends Node

var john_smith_scene = preload('res://john_smith.tscn')
var john_script = preload('res://npc/john_smith.gd')

func spawn_john():
	var npc_js = john_smith_scene.instantiate()
	
	npc_js.set_script(john_script)
	
	add_child(npc_js)
	
	npc_js.global_position = Vector3(-22.408, 0, 19.865)
	
func _ready() -> void:
	print("restaurant manager")
	await get_tree().create_timer(2.0).timeout
	spawn_john()

func _process(delta: float) -> void:
	pass

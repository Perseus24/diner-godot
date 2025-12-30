extends Node3D

var occupied = false
var occupant = null

@onready var sit_position = $Marker3D
func _ready() -> void:
	pass 

func is_occupied():
	return occupied

func sit_down(npc):
	if occupied: 
		return 
	
	occupied = true
	occupant = npc
	return
	
func get_sit_position():
	return sit_position.global_position

func _process(delta: float) -> void:
	pass

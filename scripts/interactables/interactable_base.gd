extends Node3D
class_name Interactable

signal interacted(character)

@export var interaction_text:String = "Interact"
@export var interaction_distance:float = 2.0
@export var can_interact: bool = true

func interact(interactor): 
	if !can_interact:
		return
	
	interacted.emit(interactor)
	print("[Interactable] ", name, " was interacted with")

func get_interaction_text() -> String:
	return interaction_text

func can_be_interacted() -> bool:
	return can_interact
	

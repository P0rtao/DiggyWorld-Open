extends Node

@export var jump_force : float

func _process(_delta: float) -> void:
	if owner.is_on_floor() and owner.can_jump :
		owner.velocity.y = -jump_force

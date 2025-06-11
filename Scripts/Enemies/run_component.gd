extends Node2D

@export var walkspeed : float = 100
@export var gravity : float = 850.0
@export var max_fall_speed : float = 450.0

var player : CharacterBody2D

func _ready() -> void:
	player = get_tree().get_first_node_in_group("Player")

func _process(delta: float) -> void:
	if owner.can_walk :
		walk(delta)
	else :
		if owner.is_on_floor() :
			owner.velocity.x = move_toward(owner.velocity.x, 0, 350 * delta)
	
	if !owner.is_on_floor() :
		if owner.velocity.y > max_fall_speed :
			owner.velocity.y -= gravity * delta
		else :
			owner.velocity.y += gravity * delta
	
	

func walk(delta) -> void :
	owner.velocity.x = move_toward(owner.velocity.x, walkspeed * owner.direction, 150 * delta)
	
	if player.position.x > owner.position.x :
		owner.direction = 1
	else :
		owner.direction = -1
	

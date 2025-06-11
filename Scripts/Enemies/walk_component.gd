extends Node

# Timer stops enemies from colliding 2 times with the same wall so they dont get stuck
@onready var wall_collide_timer: Timer = $WallCollideTimer

@export var walkspeed : float
@export var gravity : float = 850.0
@export var max_fall_speed : float = 450.0

func _process(delta: float) -> void:
	if owner.can_walk :
		walk()
	else :
		if owner.is_on_floor() :
			owner.velocity.x = move_toward(owner.velocity.x, 0, 250 * delta)
	
	if !owner.is_on_floor() :
		if owner.velocity.y > max_fall_speed :
			owner.velocity.y -= gravity * delta
		else :
			owner.velocity.y += gravity * delta
	
	

func walk() -> void :
	owner.velocity.x = walkspeed * owner.direction
	
	if owner.is_on_wall() and wall_collide_timer.is_stopped() :
		wall_collide_timer.start()
		owner.direction = -owner.direction
	

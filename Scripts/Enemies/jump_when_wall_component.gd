extends Node2D

@onready var raycast: RayCast2D = $RayCast2D

func _ready() -> void:
	raycast.target_position = Vector2(32 * owner.direction, 0)
	raycast.rotation = deg_to_rad(45 * -owner.direction)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	raycast.target_position = Vector2(32 * owner.direction, 0)
	raycast.rotation = deg_to_rad(45 * -owner.direction)
	
	if owner.is_on_floor() and raycast.is_colliding() :
		owner.velocity.y = -300

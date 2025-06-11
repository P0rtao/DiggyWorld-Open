extends CharacterBody2D

var can_walk : bool = true
@export var direction : int = 1

var in_water : bool = false

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

func _process(_delta: float) -> void:
	if direction == 1 :
		animated_sprite_2d.flip_h = false
	else :
		animated_sprite_2d.flip_h = true
	
	move_and_slide()


func _on_interaction_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") :
		body.hurt()

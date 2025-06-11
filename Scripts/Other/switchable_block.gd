extends StaticBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	update_block_state()

func update_block_state() -> void:
	if is_in_group("BlockON") :
		animated_sprite_2d.play("ON")
		hitbox.set_deferred("disabled", false)
	
	if is_in_group("BlockOFF") :
		animated_sprite_2d.play("OFF")
		hitbox.set_deferred("disabled", true)

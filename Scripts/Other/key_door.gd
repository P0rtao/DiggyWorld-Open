extends StaticBody2D

var lock_particle : PackedScene = preload("res://Scenes/Other/lock_particle.tscn")

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: CollisionShape2D = $CollisionShape2D
@onready var area_2d: Area2D = $Area2D


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Key") :
		animated_sprite_2d.play("Open")
		hitbox.set_deferred("disabled", true)
		area_2d.set_deferred("monitoring", false)
		
		var new = lock_particle.instantiate()
		new.position = position
		add_sibling(new)
		
		body.queue_free()


func _on_animated_sprite_2d_animation_finished() -> void:
	queue_free()

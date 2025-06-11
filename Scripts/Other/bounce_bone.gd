extends AnimatedSprite2D

var speed : float = -200
var gravity : float = 850
var particle_scene : PackedScene = preload("res://Scenes/Other/bone_particle.tscn")

func _process(delta: float) -> void:
	position.y += speed * delta
	speed += gravity * delta


func _on_bounce_timer_timeout() -> void:
	var new_particle = particle_scene.instantiate()
	new_particle.position = position
	add_sibling(new_particle)
	GameManager.add_bones(1)
	queue_free()

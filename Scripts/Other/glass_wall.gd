extends StaticBody2D

var particle : PackedScene = preload("res://Scenes/Other/glass_particle.tscn")

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") or body.is_in_group("Carryable") :
		if body.velocity.x > 145 or body.velocity.x < -145 :
			
			for i in range(6) :
				var new = particle.instantiate()
				new.speedx = body.velocity.x / randi_range(2, 4)
				new.speedy = randi_range(-250, -150)
				new.position = position + Vector2(randi_range(-8, 0), randi_range(-32, 32))
				add_sibling(new)
			AudioManager.play_audio(AudioManager.shatter_audio)
			queue_free()

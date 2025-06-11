extends Area2D

var particle_scene : PackedScene = preload("res://Scenes/Other/bone_particle.tscn")

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") :
		body.powerup_state = body.PlayerState.SwordState
		
		AudioManager.play_audio(AudioManager.collect_audio)
		
		var new_particle = particle_scene.instantiate()
		new_particle.position = position
		add_sibling(new_particle)
		
		queue_free()

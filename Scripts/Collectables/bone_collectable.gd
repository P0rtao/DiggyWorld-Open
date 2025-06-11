extends Area2D

var particle_scene : PackedScene = preload("res://Scenes/Other/bone_particle.tscn")


func _on_body_entered(body) -> void:
	if body.is_in_group("Player") :
		AudioManager.play_audio(AudioManager.collect_audio)
		
		var new_particle = particle_scene.instantiate()
		new_particle.position = position
		add_sibling(new_particle)
		
		GameManager.add_bones(1)
		
		queue_free()

extends Node2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") :
		AudioManager.play_audio(AudioManager.bounce_audio)
		body.velocity.y = -500
		if body.carried_body == null :
			body.game_state = body.PlayerState.RampJump
		animated_sprite_2d.play("Bounce")
	
	if body.is_in_group("Enemy") or body.is_in_group("Carryable") :
		AudioManager.play_audio(AudioManager.bounce_audio)
		body.velocity.y = -500
		animated_sprite_2d.play("Bounce")


func _on_animated_sprite_2d_animation_finished() -> void:
	animated_sprite_2d.play("Still")

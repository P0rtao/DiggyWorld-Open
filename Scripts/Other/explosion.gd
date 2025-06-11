extends Area2D


func _ready() -> void:
	AudioManager.play_audio(AudioManager.big_stomp_audio)


func _on_body_entered(body: Node2D) -> void:
	if body.has_method("destroy_brick") :
		body.destroy_brick()
		return
	
	if body.has_method("defeat") :
		body.defeat()
		return
	
	if body.has_method("bounce") :
		body.bounce()
		return
	
	if body.is_in_group("Player") :
		body.hurt()
		return


func _on_timer_timeout() -> void:
	queue_free()

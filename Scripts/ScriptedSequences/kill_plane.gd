extends Area2D


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") :
		body.die()
		return
	
	if body.is_in_group("Enemy") or body.is_in_group("Carryable") :
		body.queue_free()

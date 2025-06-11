extends Sprite2D


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") : 
		var tween = get_tree().create_tween()
		tween.tween_property(self, "position", Vector2(position.x + 50, position.y), 5)
		
		$Area2D.queue_free()

extends AnimatedSprite2D

var speed : Vector2 = Vector2(130, -230)
var gravity : float = 850

func _process(delta: float) -> void:
	position.x += speed.x * delta
	position.y += speed.y * delta
	speed.y += gravity * delta


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()

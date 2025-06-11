extends AnimatedSprite2D

var gravity : float = 650

var speedy : float = -350

func _process(delta: float) -> void:
	position.y += speedy * delta
	
	speedy += gravity * delta


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()

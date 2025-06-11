extends AnimatedSprite2D

var speedx = 50
var speedy : float = -200
var gravity : float = 850

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position.y += speedy * delta
	position.x += speedx * delta
	speedy += gravity * delta


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()

extends Sprite2D

var speedx : float = 50
var speedy : float = -200
var gravity : float = 850

func _process(delta: float) -> void:
	position.y += speedy * delta
	position.x += speedx * delta
	
	speedy += gravity * delta


func _on_visible_on_screen_enabler_2d_screen_exited() -> void:
	queue_free()

extends AnimatedSprite2D

var gravity : float = 650

var speedx : float = 0
var speedy : float = 0

func _ready() -> void:
	speedx = randf_range(-150, 150)
	speedy = randf_range(-350, -150)

func _process(delta: float) -> void:
	position.x += speedx * delta
	
	position.y += speedy * delta
	
	speedy += gravity * delta

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()

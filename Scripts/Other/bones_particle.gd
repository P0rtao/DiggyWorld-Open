extends Node2D

@onready var sprite_1: AnimatedSprite2D = $Sprite1
@onready var sprite_2: AnimatedSprite2D = $Sprite2
@onready var sprite_3: AnimatedSprite2D = $Sprite3
@onready var sprite_4: AnimatedSprite2D = $Sprite4

var speedx : float = 50
var speedy : float = -200
var gravity : float = 850

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	sprite_1.position.y += speedy * delta
	sprite_1.position.x += speedx * delta
	sprite_2.position.y += speedy * delta
	sprite_2.position.x -= speedx * delta
	sprite_3.position.y += speedy * delta
	sprite_3.position.x += speedx * delta
	sprite_4.position.y += speedy * delta
	sprite_4.position.x -= speedx * delta
	speedy += gravity * delta


func _on_particle_time_timeout() -> void:
	queue_free()

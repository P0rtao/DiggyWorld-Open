extends CharacterBody2D

var barrel : PackedScene = preload("res://Scenes/Entities/rolling_barrel.tscn")
var enabled : bool = false
var direction : int = 1
var dead : bool = false

var gravity : float = 850.0

@onready var throw_timer: Timer = $ThrowTimer
@onready var grab_timer: Timer = $GrabTimer
@onready var idle_timer: Timer = $IdleTimer
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

func _process(delta: float) -> void:
	if !enabled :
		return
	
	if direction == 1 :
		animated_sprite_2d.flip_h = true
	else :
		animated_sprite_2d.flip_h = false
	
	if dead :
		$CollisionShape2D.set_deferred("disabled", true)
		animated_sprite_2d.play("Death")
		idle_timer.stop()
		grab_timer.stop()
		throw_timer.stop()
		$BarrelSprite.visible = false
		velocity.y += gravity * delta
		move_and_slide()

func enable() -> void:
	enabled = true
	grab_timer.start()

func throw_barrel() -> void:
	var new_barrel = barrel.instantiate()
	new_barrel.position = position + Vector2(8 * direction, 0)
	new_barrel.direction = direction
	new_barrel.velocity.y = -200
	add_sibling(new_barrel)

func _on_grab_timer_timeout() -> void:
	$BarrelSprite.visible = true
	throw_timer.wait_time = randf_range(0.2, 1)
	throw_timer.start()

func _on_throw_timer_timeout() -> void:
	$BarrelSprite.visible = false
	animated_sprite_2d.play("Throw")
	
	var should_turn : int = randi_range(0, 1)
	if should_turn == 1 :
		direction = -direction
	
	throw_barrel()
	idle_timer.start()

func _on_idle_timer_timeout() -> void:
	animated_sprite_2d.play("Idle")
	grab_timer.wait_time = randf_range(0.5, 1)
	grab_timer.start()

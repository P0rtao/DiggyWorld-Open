extends Node2D

@onready var animation_sprite: AnimatedSprite2D = $"../AnimatedSprite2D"
@onready var hitbox: CollisionShape2D = $"../CollisionShape2D"
@onready var area_2d: Area2D = $Area2D
@onready var bounce_time: Timer = $BounceTimer

var default_scene : PackedScene = preload("res://Scenes/Other/bounce_bone.tscn")

var og_pos : float
var bounce_speed : float = -100
var speed : float = 0
var gravity : float = 850
var hit : bool = false


func _ready() -> void :
	og_pos = animation_sprite.position.y

func _process(delta: float) -> void :
	if bounce_time.is_stopped() :
		animation_sprite.position.y = og_pos
	else :
		animation_sprite.position.y += speed * delta
		speed += gravity * delta

func bounce() -> void :
	bounce_time.start()
	
	animation_sprite.position.y = og_pos
	speed = bounce_speed
	hit = true
	owner.ammount -= 1
	if owner.ammount >= 0 :
		release_content()
	if owner.ammount < -1 :
		owner.ammount = -1

func release_content() -> void :
	var new_scene
	
	if owner.content :
		new_scene = owner.content.instantiate()
		new_scene.position = owner.position
		owner.call_deferred("add_sibling", new_scene)
		
		AudioManager.play_audio(AudioManager.life_audio)
		
		var tween = get_tree().create_tween()
		tween.tween_property(new_scene, "position", owner.position - Vector2(0, 16), 0.3)
	else :
		new_scene = default_scene.instantiate()
		new_scene.position = owner.position
		owner.call_deferred("add_sibling", new_scene)
		
		AudioManager.play_audio(AudioManager.collect_audio)


func _on_area_2d_body_entered(body) -> void:
	if not hit :
		if body.is_in_group("Player") or body.is_in_group("Carryable") :
			bounce()


func _on_bounce_timer_timeout() -> void:
	if owner.content and owner.ammount > 0 and owner.start_ammount > 0 :
		hit = false
	elif owner.ammount > 0 and owner.start_ammount > 0 :
		hit = false
	elif owner.start_ammount == 0 :
		hit = false
	else :
		animation_sprite.play("hit")

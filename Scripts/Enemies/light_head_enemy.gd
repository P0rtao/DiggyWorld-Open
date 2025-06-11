extends CharacterBody2D
var head_dropped : PackedScene = preload("res://Scenes/Entities/light_head_carryable.tscn")


var can_walk : bool = true
var can_jump_on : bool = true
var in_water : bool = false
@export var direction : int = 1

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var point_light_2d: PointLight2D = $PointLight2D
@onready var visible_notifier: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D

func _ready() -> void:
	if visible_notifier.is_on_screen() :
		process_mode = PROCESS_MODE_INHERIT
	else :
		process_mode = Node.PROCESS_MODE_DISABLED

func _process(_delta: float) -> void:
	animate()
	
	if is_in_group("Enemy") :
		move_and_slide()

func animate() -> void :
	if direction == 1 :
		animated_sprite_2d.flip_h = true
	else :
		animated_sprite_2d.flip_h = false
	
	if point_light_2d != null :
		point_light_2d.position.x = 48 * direction

func defeat() -> void :
	AudioManager.play_audio(AudioManager.stomp_audio)
	remove_from_group("Enemy")
	can_jump_on = false
	can_walk = false
	$InteractionHitbox/CollisionShape2D.set_deferred("disabled", true)
	animated_sprite_2d.play("Death")
	
	var new = head_dropped.instantiate()
	new.velocity = Vector2(10 * direction, -50)
	new.direction = direction
	new.position = position + Vector2(0, -4)
	call_deferred("add_sibling", new)
	point_light_2d.queue_free()
	
	await animated_sprite_2d.animation_finished
	queue_free()


func _on_on_jump_component_jumped_on() -> void:
	defeat()


func _on_interaction_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") :
		if body.velocity.y > 0 :
			return
		
		if body.sliding :
			defeat()
		
		body.hurt()


func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	process_mode = PROCESS_MODE_INHERIT


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	process_mode = PROCESS_MODE_DISABLED
	if !is_in_group("Enemy") : 
		queue_free()


func _on_on_ground_pound_component_ground_pound_on() -> void:
	defeat()

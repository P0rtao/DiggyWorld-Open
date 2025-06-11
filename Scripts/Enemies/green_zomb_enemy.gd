extends CharacterBody2D

@onready var animation_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var on_screen_notifier: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D
@onready var hitbox: CollisionShape2D = $CollisionShape2D
@onready var interaction_hitbox: Area2D = $InteractionHitbox


var can_walk : bool = true
var can_jump_on : bool = true
var in_water : bool = false

@export var direction : int = -1


func _ready() -> void:
	if on_screen_notifier.is_on_screen() :
		process_mode = PROCESS_MODE_INHERIT
	else :
		process_mode = PROCESS_MODE_DISABLED


func _process(_delta: float) -> void:
	animate()
	
	move_and_slide()

func animate() -> void :
	if direction == 1 :
		animation_sprite.flip_h = true
	else :
		animation_sprite.flip_h = false

func defeat() -> void :
	AudioManager.play_audio(AudioManager.stomp_audio)
	
	remove_from_group("Enemy")
	animation_sprite.play("Death")
	hitbox.set_deferred("disabled", true)
	interaction_hitbox.set_deferred("monitoring", false)
	
	can_walk = false
	velocity = Vector2(0, -300)


func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	process_mode = PROCESS_MODE_INHERIT


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	if !is_in_group("Enemy") :
		queue_free()
		return
	process_mode = PROCESS_MODE_DISABLED


func _on_interaction_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") :
		if body.velocity.y > 0 :
			return
		
		if body.sliding :
			defeat()
			return
		
		body.hurt()


func _on_on_jump_component_jumped_on() -> void:
	defeat()


func _on_on_ground_pound_component_ground_pound_on() -> void:
	defeat()

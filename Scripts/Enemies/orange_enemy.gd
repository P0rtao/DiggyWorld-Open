extends CharacterBody2D

@onready var animation_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var on_screen_notifier: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D
@onready var interaction_hitbox: Area2D = $InteractionHitbox
@onready var flipped_timer: Timer = $FlippedTimer
@onready var hitbox: CollisionShape2D = $CollisionShape2D
@onready var can_hurt_delay: Timer = $CanHurtDelay

@export var direction : int = -1
var can_hurt : bool = false
var can_walk : bool = true
var can_jump_on : bool = true
var flipped_over : bool = false
var inwall : bool = false
var in_water : bool = false


func _ready() -> void :
	can_hurt_delay.start()
	if on_screen_notifier.is_on_screen() or is_in_group("BossSpawned") :
		process_mode = PROCESS_MODE_INHERIT
	else :
		process_mode = PROCESS_MODE_DISABLED
	

func _process(_delta : float) -> void :
	animate()
	
	if inwall :
		in_wall()
	
	# Check for group enemy because if enemy is dead, its removed from it and shouldnt collide
	if is_in_group("Enemy") :
		if is_in_group("Carried") :
			hitbox.set_deferred("disabled", true)
			# End function early because when carried no need to move
			return
		else :
			hitbox.set_deferred("disabled", false)
	
	
	move_and_slide()
	

func in_wall() -> void :
	if !is_in_group("Carried") :
		defeat()

func animate() -> void :
	if direction == 1 :
		animation_sprite.flip_h = true
	else :
		animation_sprite.flip_h = false
	
	if flipped_over :
		animation_sprite.play("FlippedOver")
	else :
		animation_sprite.play("Walking")
	
	if flipped_timer.time_left < 3 :
		animation_sprite.speed_scale = 2
	
	if flipped_timer.is_stopped() or flipped_timer.time_left >= 2 :
		animation_sprite.speed_scale = 1

func defeat() -> void :
	AudioManager.play_audio(AudioManager.stomp_audio)
	
	hitbox.set_deferred("disabled",true)
	interaction_hitbox.set_deferred("monitoring", false)
	
	flipped_over = true
	can_jump_on = false
	can_walk = false
	can_hurt = false
	
	velocity.x = -100 * randi_range(-1, 1)
	velocity.y = -150
	
	flipped_timer.stop()
	
	remove_from_group("Enemy")
	remove_from_group("Carryable")


func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	process_mode = PROCESS_MODE_INHERIT


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	if !is_in_group("Enemy") or is_in_group("BossSpawned") :
		queue_free()
		return
	process_mode = PROCESS_MODE_DISABLED



func _on_on_jump_component_jumped_on() -> void:
	AudioManager.play_audio(AudioManager.stomp_audio)
	
	can_jump_on = false
	can_walk = false
	flipped_over = true
	can_hurt = false
	
	add_to_group("Carryable")
	
	flipped_timer.start()


func _on_flipped_timer_timeout() -> void:
	can_jump_on = true
	can_walk = true
	flipped_over = false
	can_hurt = true
	
	remove_from_group("Carryable")
	
	velocity.y = -50


func _on_interaction_hitbox_body_entered(body) -> void:
	if body == self :
		return
	
	if body is TileMapLayer :
		inwall = true
	
	if body.is_in_group("Player") :
		if can_hurt and body.velocity.y <= 0 and !body.sliding :
			body.hurt()
		elif body.sliding :
			defeat()
	
	# Weird If Statement, prevents weird behaviour with armored enemy
	if body.is_in_group("Carryable") and body.velocity != Vector2(0, 0) :
		if is_in_group("Carryable") and body.is_in_group("Enemy") :
			body.defeat()
		defeat()


func _on_can_hurt_delay_timeout() -> void:
	if !flipped_over :
		can_hurt = true


func _on_interaction_hitbox_body_exited(body: Node2D) -> void:
	if body is TileMapLayer :
		inwall = false


func _on_on_ground_pound_component_ground_pound_on() -> void:
	defeat()

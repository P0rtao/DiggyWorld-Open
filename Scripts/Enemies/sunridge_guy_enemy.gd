extends CharacterBody2D

var sword_particle : PackedScene = preload("res://Scenes/Other/sword_particle.tscn")

@onready var animation_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var on_screen_notifier: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D
@onready var stun_timer: Timer = $StunTimer
@onready var hitbox: CollisionShape2D = $CollisionShape2D
@onready var interaction_hitbox: Area2D = $InteractionHitbox


var can_walk : bool = true
var can_jump_on : bool = true
var stunned : bool = false
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

func stun() -> void :
	if !stunned :
		AudioManager.play_audio(AudioManager.big_stomp_audio)
		
		$SwordComponent.enabled = false
		stun_timer.start()
		can_walk = false
		can_jump_on = true
		stunned = true
		velocity.x = -150 * direction
		animation_sprite.play("Stun")
	else :
		defeat()

func defeat() -> void :
	remove_from_group("Enemy")
	stun_timer.stop()
	AudioManager.play_audio(AudioManager.stomp_audio)
	
	hitbox.set_deferred("disabled",true)
	interaction_hitbox.set_deferred("monitoring", false)
	
	animation_sprite.play("Death")
	velocity.x = -100 * direction
	velocity.y = -150
	
	var new = sword_particle.instantiate()
	new.position = position
	add_sibling(new)

func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	process_mode = PROCESS_MODE_INHERIT


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	if !is_in_group("Enemy") :
		queue_free()
		return
	process_mode = PROCESS_MODE_DISABLED


func _on_on_jump_component_jumped_on() -> void:
	if !stunned :
		stun_timer.start()
		AudioManager.play_audio(AudioManager.bounce_audio)
		animation_sprite.play("Defend")
		can_walk = false
		can_jump_on = false
		velocity.x = -150 * direction
	else :
		defeat()


func _on_stun_timer_timeout() -> void:
	animation_sprite.play("Walk")
	
	$SwordComponent.hitbox.set_deferred("disabled", false)
	$SwordComponent.enabled = true
	can_walk = true
	can_jump_on = true
	stunned = false


func _on_on_ground_pound_component_ground_pound_on() -> void:
	stun()

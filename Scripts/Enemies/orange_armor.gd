extends CharacterBody2D

@export var direction : int = -1
var can_walk : bool = true
var can_jump_on : bool = true
var in_water : bool = false

@onready var animation_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var on_screen_notifier: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D
@onready var interaction_hitbox: Area2D = $InteractionHitbox
@onready var hitbox: CollisionShape2D = $CollisionShape2D
var enemy_scene : PackedScene = preload("res://Scenes/Entities/orange_enemy.tscn")
var helmet_scene : PackedScene = preload("res://Scenes/Other/helmet.tscn")

func _ready() -> void :
	# This stops the enemy from walking off of it's starting point before the player sees it
	if on_screen_notifier.is_on_screen() :
		process_mode = PROCESS_MODE_INHERIT
	else :
		process_mode = PROCESS_MODE_DISABLED

func _process(_delta : float) -> void :
	animate()
	
	move_and_slide()

func animate() -> void :
	if direction == 1 :
		animation_sprite.flip_h = true
	else :
		animation_sprite.flip_h = false

func defeat() -> void :
	AudioManager.play_audio(AudioManager.stomp_audio)
	animation_sprite.flip_v = true
	hitbox.set_deferred("disabled",true)
	interaction_hitbox.set_deferred("monitoring", false)
	
	can_jump_on = false
	can_walk = false
	
	velocity.x = -100 * randi_range(-1, 1)
	velocity.y = -150
	
	remove_from_group("Enemy")


func _on_on_jump_component_jumped_on() -> void:
	AudioManager.play_audio(AudioManager.stomp_audio)
	
	var new_enemy = enemy_scene.instantiate()
	var new_helm = helmet_scene.instantiate()
	
	new_enemy.position = position
	new_helm.position = position
	
	new_enemy.direction = direction
	
	call_deferred("add_sibling", new_enemy)
	add_sibling(new_helm)
	
	queue_free()


func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	process_mode = PROCESS_MODE_INHERIT


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	if !is_in_group("Enemy") :
		queue_free()
	process_mode = PROCESS_MODE_DISABLED


func _on_interaction_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") :
		if body.velocity.y <= 0 :
			body.hurt()


func _on_on_ground_pound_component_ground_pound_on() -> void:
	defeat()

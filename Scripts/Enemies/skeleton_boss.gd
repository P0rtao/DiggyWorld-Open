extends CharacterBody2D

var spawn_particle : PackedScene = preload("res://Scenes/Other/sunridge_boss_spawn_particle.tscn")
var hit_particle : PackedScene = preload("res://Scenes/Other/skel_boss_particle.tscn")
var sword_particle : PackedScene = preload("res://Scenes/Other/sword_particle.tscn")
var head : PackedScene = preload("res://Scenes/BossFight/skeleton_boss_head.tscn")

var player : Node2D
var player_colliding : bool = false

var health : int = 8
var game_state : String = "Walk"

@onready var animation_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: CollisionShape2D = $Hitbox
@onready var interaction_hitbox: CollisionShape2D = $InteractionHitbox/CollisionShape2D
@onready var head_hitbox: CollisionShape2D = $HeadHitbox/CollisionShape2D
@onready var spin_start: Timer = $SpinStart
@onready var spin_duration: Timer = $SpinDuration


var gravity : float = 450.0
var direction : int = -1
var walk_speed : float = 25.0

func _ready() -> void:
	player = get_tree().get_first_node_in_group("Player")
	
	var new = spawn_particle.instantiate()
	new.position = position
	add_sibling(new)


func _process(delta: float) -> void:
	if game_state == "Death" :
		velocity.x = 0
		return
	
	physics(delta)
	
	
	match game_state :
		"Walk" :
			animation_sprite.play("Walk")
			walk()
		"SwordReady" :
			velocity.x = 0
			animation_sprite.play("SwordReady")
			await animation_sprite.animation_finished
			game_state = "SwordAttack"
		"SwordAttack" :
			animation_sprite.play("SwordAttack")
			
			if player_colliding :
				player.hurt()
			
			await animation_sprite.animation_finished
			game_state = "SwordCooldown"
		"SwordCooldown" :
			animation_sprite.play("SwordCooldown")
			await animation_sprite.animation_finished
			game_state = "Walk"
		"SpinReady" :
			velocity.x = 0
			animation_sprite.play("SpinReady")
			await animation_sprite.animation_finished
			walk_speed = 200
			game_state = "SpinAttack"
			spin_duration.start()
		"SpinAttack" :
			run(delta)
			animation_sprite.play("SpinAttack")
			
			if player_colliding :
				player.hurt()
			
		"SpinCooldown" :
			velocity.x = 0
			animation_sprite.play("SpinCooldown")
			await animation_sprite.animation_finished
			game_state = "Walk"
		
	if player_colliding and game_state == "Walk" :
		game_state = "SwordReady"
	
	move_and_slide()
	handle_direction()

func handle_direction() -> void :
	if direction == 1 :
		animation_sprite.flip_h = true
	else :
		animation_sprite.flip_h = false
	
	interaction_hitbox.position.x = 3 * direction
	head_hitbox.position.x = 3 * direction

func walk() -> void :
	velocity.x = walk_speed * direction
	
	if player.position.x > position.x and player.game_state != player.PlayerState.Die :
		direction = 1
	else :
		direction = -1

func run(delta : float) -> void :
	velocity.x = move_toward(velocity.x, walk_speed * direction, 150 * delta)
	
	if player.position.x > position.x :
		direction = 1
	else :
		direction = -1

func physics(delta: float) -> void :
	if !is_on_floor() :
		velocity.y += gravity * delta


func _on_interaction_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") : 
		player_colliding = true

func damage() -> void :
	AudioManager.play_audio(AudioManager.stomp_audio)
	health -= 1
	
	var new = hit_particle.instantiate()
	new.position = head_hitbox.position + Vector2(0, 16)
	add_child(new)
	
	if health <= 0 :
		die()

func die() -> void :
	game_state = "Death"
	
	var sword = sword_particle.instantiate()
	sword.position = position
	call_deferred("add_sibling", sword)
	
	animation_sprite.play("Death")
	spin_start.stop()
	spin_duration.stop()
	
	var new = head.instantiate()
	new.direction = direction
	new.position = position
	new.velocity = Vector2(-60 * direction, -150)
	call_deferred("add_sibling", new)
	await animation_sprite.animation_finished
	self.get_parent().end_boss()
	
	queue_free()

func _on_head_hitbox_body_entered(body: Node2D) -> void:
	if game_state == "Death" :
		return
	
	if body.is_in_group("Player") :
		if game_state == "SpinAttack" :
			body.hurt()
			return
		
		if body.velocity.y > 0 :
			body.game_state = body.PlayerState.Default
			body.velocity = Vector2(-200 * direction, -300)
			damage()


func _on_interaction_hitbox_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player") :
		player_colliding = false


func _on_spin_start_timeout() -> void:
	game_state = "SpinReady"


func _on_spin_duration_timeout() -> void:
	velocity.x = 0
	spin_start.start()
	game_state = "SpinCooldown"
	walk_speed = 25

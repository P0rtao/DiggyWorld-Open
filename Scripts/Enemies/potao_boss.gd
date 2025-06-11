extends CharacterBody2D

var player : Node2D
var camera : Node2D

var armor : bool = true
var armor_health : int = 6
var game_state : String = "JumpAttack"

var enemy_scene : PackedScene = preload("res://Scenes/Entities/orange_enemy.tscn")
var helmet_scene : PackedScene = preload("res://Scenes/Other/helmet.tscn")

@onready var animation_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: CollisionShape2D = $Hitbox
@onready var interaction_hitbox: Area2D = $InteractionHitbox
@onready var jump_hitbox: Area2D = $JumpHitbox
@onready var jump_timer: Timer = $JumpTimer
@onready var turn_around_timer: Timer = $TurnAroundTimer
@onready var stun_timer: Timer = $StunTimer

var gravity : float = 450.0
var max_fall_speed : float = 250.0
var direction : int = -1
var walk_speed : float = 20.0

func _ready() -> void:
	player = get_tree().get_first_node_in_group("Player")
	camera = get_tree().get_first_node_in_group("Camera")

func _process(delta: float) -> void:
	physics(delta)
	
	if game_state == "Walk" :
		walk()
	else :
		velocity.x = move_toward(velocity.x, 0, 250 * delta)
	
	animate()
	move_and_slide()
	
	# Checked after movement is applied to make sure he doesnt leave the ground and come back on same frame
	if is_on_floor() and game_state != "Stunned" :
		if game_state == "JumpAttack" :
			AudioManager.play_audio(AudioManager.big_stomp_audio)
			
			stun_timer.start()
			
			camera.cam_shake()
			
			if player.is_on_floor() :
				player.game_state = player.PlayerState.Stunned
				player.velocity = Vector2(0, 0)
			
			if !armor :
				game_state = "Stunned"
				spawn_enemy()
			else :
				game_state = "Walk"
	
	if !is_on_floor() and game_state != "JumpAttack" :
		game_state = "Dead"
		jump_timer.stop()
		turn_around_timer.stop()

func physics(delta: float) -> void :
	if !is_on_floor() :
		if velocity.y > max_fall_speed :
			velocity.y -= gravity * delta
		else :
			velocity.y += gravity * delta

func animate() -> void :
	if direction > 0 :
		animation_sprite.flip_h = true
	else :
		animation_sprite.flip_h = false
	
	match game_state :
		"Walk" :
			if armor :
				animation_sprite.play("WalkArmored")
			else :
				animation_sprite.play("Walk")
		"JumpAttack" :
			if armor :
				if velocity.y < 0 :
					animation_sprite.play("JumpArmored")
				else :
					animation_sprite.play("FallArmored")
			else :
				if velocity.y < 0 :
					animation_sprite.play("Jump")
				else :
					animation_sprite.play("Fall")
		"Stunned" :
			animation_sprite.play("Stunned")
		"Dead" :
			animation_sprite.play("Dead")

func walk() -> void :
	if player.position.x > position.x and player.game_state != player.PlayerState.Die :
		if turn_around_timer.is_stopped() :
			direction = 1
			turn_around_timer.start()
	else :
		if turn_around_timer.is_stopped() :
			direction = -1
			turn_around_timer.start()
	
	velocity.x = walk_speed * direction

func spawn_enemy() -> void :
	var enemy = enemy_scene.instantiate()
	
	enemy.add_to_group("BossSpawned")
	enemy.position = Vector2(player.position.x + 64, -300)
	
	add_sibling(enemy)

func break_armor() -> void :
	var helmet = helmet_scene.instantiate()
	
	helmet.position = position
	helmet.scale = Vector2(2, 2)
	
	add_sibling(helmet)
	
	walk_speed = 30
	armor = false

func _on_jump_timer_timeout() -> void:
	velocity.y = -350
	position.y -= 1
	game_state = "JumpAttack"


func _on_stun_timer_timeout() -> void:
	if player.game_state == player.PlayerState.Stunned :
		player.game_state = player.PlayerState.Default
	
	if game_state == "Stunned" :
		game_state = "Walk"


func _on_interaction_hitbox_body_entered(body: Node2D) -> void:
	if body == player :
		body.hurt()
	
	if body.is_in_group("Carryable") :
		if body.velocity != Vector2(0, 0) and !armor and game_state != "JumpAttack" :
			game_state = "Stunned"
			velocity.x = 200 * body.direction
			
			stun_timer.start()
			
			AudioManager.play_audio(AudioManager.stomp_audio)
		body.defeat()

func _on_jump_hitbox_body_entered(body: Node2D) -> void:
	if body == player :
		if body.velocity.y > 0 and game_state != "JumpAttack" :
			body.velocity = Vector2(-200, -300)
			armor_health -= 1
			if armor :
				modulate = Color(1, 0, 0)
				var tween = get_tree().create_tween()
				tween.tween_property(self, "modulate", Color(1, 1, 1), 0.5)
			
			if body.game_state == body.PlayerState.GroundPound :
				body.game_state = body.PlayerState.Default
				armor_health -= 1
				if !armor :
					game_state = "Stunned"
					velocity.x = 200 * body.direction
					
					stun_timer.start()
			
					AudioManager.play_audio(AudioManager.stomp_audio)
				
			
			if !armor :
				game_state = "Stunned"
				stun_timer.start()
				
				AudioManager.play_audio(AudioManager.bounce_audio)
			else :
				AudioManager.play_audio(AudioManager.stomp_audio)
			
			if armor_health == 0 :
				break_armor()
		else :
			body.hurt()

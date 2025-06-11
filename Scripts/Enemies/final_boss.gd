extends CharacterBody2D
signal boss_defeated

var bomb_scene : PackedScene = preload("res://Scenes/Entities/bomb.tscn")
var mech_particle_scene : PackedScene = preload("res://Scenes/Other/mech_particle.tscn")
var tiger_die_scene : PackedScene = preload("res://Scenes/Other/tiger_die.tscn")

var active : bool = false

@export var direction : int = -1

var gravity : float = 850.0

var player : Node2D
var camera : Node2D

var health : int = 16
var game_state : String = "Fall"
var has_shot : bool = false

func _ready() -> void:
	player = get_tree().get_first_node_in_group("Player")
	camera = get_tree().get_first_node_in_group("Camera")

func _process(delta: float) -> void:
	if !active :
		return
	
	move_and_slide()
	handle_direction()
	
	match game_state :
		"Idle" :
			velocity = Vector2(0, 0)
			if $AttackTimer.is_stopped() :
				$AttackTimer.start()
		"Shoot" :
			var new = bomb_scene.instantiate()
			new.position = $LeftHand.global_position + Vector2(26 * direction, 0)
			new.direction = direction
			new.velocity.x = 150 * direction
			add_sibling(new)
			
			var tween = get_tree().create_tween()
			tween.tween_property($LeftHand, "offset", Vector2(-5 * direction, 0), 0.1)
			tween.tween_property($LeftHand, "offset", Vector2(0, 0), 0.2)
			game_state = "Idle"
		"JumpStart" :
			$AnimationHandler.play("Jump")
			await $AnimationHandler.animation_finished
			game_state = "Jump"
		"Jump" :
			velocity.y = -500
			if $JumpUpDuration.is_stopped() :
				$JumpUpDuration.start()
		"JumpTrack" :
			if player.position.x > position.x :
				direction = 1
			elif player.position.x < position.x :
				direction = -1
			
			position.x = player.position.x
			
			if $JumpTrackDuration.is_stopped() :
				$JumpTrackDuration.start()
		"Fall" :
			$AnimationHandler.play("Falling")
			
			if !is_on_floor() :
				velocity.y += gravity * delta
			else :
				game_state = "Land"
				camera.cam_shake()
				AudioManager.play_audio(AudioManager.big_stomp_audio)
				
				if player.is_on_floor() :
					$StunTimer.start()
					player.game_state = player.PlayerState.Stunned
					player.velocity = Vector2(0, 0)
		"Land" :
			$AnimationHandler.play("Land")
			await $AnimationHandler.animation_finished
			has_shot = false
			game_state = "Idle"
	

func handle_direction() -> void :
	if direction == 1 :
		$Tiger.flip_h = true
		$Body.flip_h = true
		$LeftLeg.flip_h = true
		$RightLeg.flip_h = true
		$LeftShoulder.flip_h = true
		$LeftArm.flip_h = true
		$LeftHand.flip_h = true
		$RightHand.flip_h = true
		
		
	else :
		$Tiger.flip_h = false
		$Body.flip_h = false
		$LeftLeg.flip_h = false
		$RightLeg.flip_h = false
		$LeftShoulder.flip_h = false
		$LeftArm.flip_h = false
		$LeftHand.flip_h = false
		$RightHand.flip_h = false
		
	
	$LeftLeg.position.x = 6 * -direction
	$RightLeg.position.x = 12 * direction
	$LeftShoulder.position.x = 7 * -direction
	$LeftArm.position.x = 7 * -direction
	$LeftHand.position.x = 3 * -direction
	$RightHand.position.x = 19 * direction
	
	$BodyHitbox/CollisionShape2D.position = $Body.position + $Body.offset + Vector2(0, 13)
	$LeftLegHitbox/CollisionShape2D.position = $LeftLeg.position + $LeftLeg.offset + Vector2(3, 5)
	$RightLegHitbox/CollisionShape2D.position = $RightLeg.position + $RightLeg.offset + Vector2(3, 5)

func damage(dmg : int = 1) -> void :
	if health <= 0 :
		defeat()
		return
	
	AudioManager.play_audio(AudioManager.stomp_audio)
	health -= dmg
	$Tiger.play("Shock")
	
	$Body.modulate = Color(1, 0, 0)
	var tween = get_tree().create_tween()
	tween.tween_property($Body, "modulate", Color(1, 1, 1), 0.5)

func defeat() -> void :
	for i in range(9) :
		var new = mech_particle_scene.instantiate()
		new.set_frame(i)
		new.position = position
		call_deferred("add_sibling", new)
	
	var tiger = tiger_die_scene.instantiate()
	tiger.position = position
	call_deferred("add_sibling", tiger)
	
	AudioManager.play_audio(AudioManager.big_stomp_audio)
	
	boss_defeated.emit()
	queue_free()

func _on_jump_up_duration_timeout() -> void:
	game_state = "JumpTrack"
	velocity.y = 0


func _on_attack_timer_timeout() -> void:
	var rand : int = randi_range(1, 4)
	
	if rand == 1 :
		game_state = "JumpStart"
	else :
		if has_shot :
			game_state = "JumpStart"
		else :
			game_state = "Shoot"
			has_shot = true


func _on_jump_track_duration_timeout() -> void:
	game_state = "Fall"


func _on_stun_timer_timeout() -> void:
	player.game_state = player.PlayerState.Default


func _on_left_leg_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") :
		body.hurt()
		$Tiger.play("Laugh")


func _on_right_leg_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") :
		body.hurt()
		$Tiger.play("Laugh")


func _on_body_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") :
		body.hurt()
		$Tiger.play("Laugh")
	
	if body.is_in_group("Carryable") :
		if body.velocity != Vector2(0, 0) :
			damage(2)
			if body.has_method("defeat") :
				body.defeat()

func _on_head_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") :
		if body.velocity.y > 0 :
			if body.game_state == body.PlayerState.GroundPound :
				damage(2)
				body.game_state = body.PlayerState.Default
			else :
				damage()
			body.velocity = Vector2(250 * direction, -150)

func _on_tiger_animation_finished() -> void:
	$Tiger.play("Idle")

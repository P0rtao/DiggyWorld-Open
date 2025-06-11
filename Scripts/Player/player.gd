extends CharacterBody2D

# Dust Particle is spawned when skidding
var dust_particle : PackedScene = preload("res://Scenes/Other/dust_particle.tscn")
# This particle spawns when hitting the ground during a ground pound
var gp_dust_particle : PackedScene = preload("res://Scenes/Other/ground_pound_dust_particle.tscn")
# Particle Spawned when sword attacking
var sword_attack_particle : PackedScene = preload("res://Scenes/Other/sword_attack_particle.tscn")
# Particle Spawned when dropping sword
var sword_particle : PackedScene = preload("res://Scenes/Other/sword_particle.tscn")

# Gravity and Max Falling Speed Change depending on if Jump is pressed
var gravity : float = 850.0
var max_fall_speed : float = 450.0

# Every type of ground
enum GroundType {
	Flat,
	SlopeRight,
	SlopeLeft,
	SteepRight,
	SteepLeft
}

enum PlayerState {
	Default,
	WallSlide,
	GroundPound,
	Win,
	Die,
	Stunned,
	Entering,
	NP,
	SwordState,
	SwordDJump,
	SwordAttack,
	Swim,
	RampJump,
}

# Max Speed is the maximum speed while on flat ground (Going down slopes surpasses it)
var acceleration : float = 1.5
var max_speed : float = 75.0
var deceleration : float = 3.0
var jump_force : float = 330.0
const speed_cap : float = 250.0
var can_cancel_jump : bool = false
var crouching : bool = false
var sliding : bool = false
var jump_fly : bool = false
var air_spin : bool = false
var can_jump : bool = false
var slope_boost : float = 0.0
var ground_type : GroundType = GroundType.Flat
var water_surface : bool = false
var is_hurt : bool = false
# Controls player behaviour
var game_state : PlayerState = PlayerState.Default
var powerup_state : PlayerState = PlayerState.NP
var double_jump : bool = false
var can_move : bool = true

# Keep reference to carried body to update position later
var carried_body : Node2D = null

var direction : int = 1

# Child Nodes
@onready var animation_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: CollisionShape2D = $CollisionShape2D
@onready var spin_cooldown: Timer = $AirSpinCooldown
@onready var dust_timer: Timer = $DustTimer
@onready var i_frames: Timer = $IFrames
@onready var flicker_timer: Timer = $FlickerTimer
@onready var death_timer: Timer = $DeathTimer
@onready var camera : Node2D = $"../Camera"
@onready var interaction_hitbox: Area2D = $InteractionHitbox
@onready var jump_delay: Timer = $JumpDelay
@onready var coyote_time: Timer = $CoyoteTime
@onready var sword_hitbox: CollisionShape2D = $SwordHitbox/CollisionShape2D
@onready var carry_delay: Timer = $CarryDelay
@onready var ground_pound_timer: Timer = $GroundPoundTimer
@onready var wall_slide_detector: RayCast2D = $WallSlideDetector

func _physics_process(delta: float) -> void:
	wall_slide_detector.target_position.x = 6 * direction
	
	
	match game_state :
		PlayerState.Win :
			if carried_body != null :
				drop_body()
			player_animation()
			velocity = Vector2(0, 0)
		PlayerState.Entering :
			if carried_body != null :
				drop_body()
			player_animation()
			velocity = Vector2(0, 0)
		PlayerState.Die :
			gravity = 850.0
			max_fall_speed = 450.0
			if carried_body != null :
				drop_body()
			player_physics(delta)
			player_animation()
			move_and_slide()
		PlayerState.Stunned :
			if carried_body != null :
				drop_body()
			player_physics(delta)
			player_animation()
			move_and_slide()
		PlayerState.WallSlide :
			animation_sprite.play("WallSlide")
			velocity.y = 75
			crouching = false
			create_dust(-8)
			
			if Input.is_action_pressed("Left") :
				velocity.x = -20
			elif Input.is_action_pressed("Right") :
				velocity.x = 20
			else :
				velocity.x = 0
			
			if Input.is_action_just_pressed("Jump") :
				AudioManager.play_audio(AudioManager.jump_audio)
				velocity = Vector2(max_speed * -direction, -jump_force)
				direction = -direction
				game_state = PlayerState.Default
				jump_fly = true
				can_cancel_jump = true
				air_spin = false
			
			if is_on_floor() or !wall_slide_detector.is_colliding():
				game_state = PlayerState.Default
				jump_fly = false
			
			move_and_slide()
			
		PlayerState.GroundPound :
			animation_sprite.play("GroundPound")
			move_and_slide()
			if is_on_floor() :
				get_ground_type()
				match ground_type :
					GroundType.SlopeRight :
						velocity.x = max_speed
					GroundType.SlopeLeft :
						velocity.x = -max_speed
					GroundType.SteepRight :
						velocity.x = speed_cap
					GroundType.SteepLeft :
						velocity.x = -speed_cap
				
				game_state = PlayerState.Default
				AudioManager.play_audio(AudioManager.stomp_audio)
				if Input.is_action_pressed("Jump") :
					air_spin = false
					jump_fly = false
					can_cancel_jump = true
					velocity.y = -jump_force - 75
				var new_gpdust = gp_dust_particle.instantiate()
				new_gpdust.position = position + Vector2(0, 8)
				add_sibling(new_gpdust)
		PlayerState.Swim :
			jump_fly = true
			can_cancel_jump = true
			crouching = false
			
			if powerup_state == PlayerState.SwordDJump :
				powerup_state = PlayerState.SwordState
			
			water_physics(delta)
			player_water_movement()
			player_animation()
			move_and_slide()
		PlayerState.Default :
			player_physics(delta)
			if powerup_state != PlayerState.NP :
				match powerup_state :
					PlayerState.SwordState :
						if carried_body != null :
							drop_body()
						
						if can_move :
							player_sword_movement()
						player_sword_animation()
					PlayerState.SwordDJump :
						if can_move :
							player_sword_movement()
						
						if is_on_floor() :
							powerup_state = PlayerState.SwordState
					PlayerState.SwordAttack :
						if can_move :
							player_sword_movement()
						sword_attack()
			elif carried_body != null :
				if can_move :
					player_carrying_movement()
					jump_fly = true
				player_carrying_animation()
			else :
				if can_move :
					player_movement()
				player_animation()
			move_and_slide()
	
		PlayerState.RampJump :
			move_and_slide()
			player_physics(delta)
			player_animation()
			player_movement()
			animation_sprite.play("RampJump")
			jump_fly = true
			air_spin = false
			
			if is_on_floor() :
				game_state = PlayerState.Default
	
	# Called after move and slide so carried body doesn't lag behind the player
	update_body(delta)

func water_physics(delta) -> void :
	if not is_on_floor():
		if velocity.y > max_fall_speed :
			velocity.y -= (gravity / 2) * delta
		else :
			velocity.y += (gravity / 2) * delta
		
	if powerup_state == PlayerState.SwordState :
		double_jump = true
		
	if velocity.x * direction < 0 :
		if Input.is_action_pressed("Sprint") or Input.is_action_pressed("Alt_Sprint") :
			acceleration = 7.5
		else :
			acceleration = 5.5
	else :
		acceleration = 1.5

func player_physics(delta) -> void:
	if not is_on_floor():
		ground_type = GroundType.Flat
		floor_snap_length = 5
		sliding = false
		if !air_spin :
			if velocity.y > max_fall_speed :
				velocity.y -= gravity * delta
			else :
				velocity.y += gravity * delta
		
		if can_jump and coyote_time.is_stopped() :
			coyote_time.start()
	
	
	# Get slope angle for slope based speed boost and set snap length
	if is_on_floor() :
		get_ground_type()
		air_spin = false
		jump_fly = false
		spin_cooldown.stop()
		coyote_time.stop()
		can_jump = true
		
		if powerup_state == PlayerState.SwordState :
			double_jump = true
		
	
	# Add acceleration when turning around for better feeling controls
	if velocity.x * direction < 0 :
		if Input.is_action_pressed("Sprint") or Input.is_action_pressed("Alt_Sprint") :
			acceleration = 7.5
		else :
			acceleration = 5.5
	else :
		acceleration = 1.5

func get_ground_type() -> void:
	if get_floor_normal() == Vector2(0, -1) :
		ground_type = GroundType.Flat
		floor_snap_length = 5
	if get_floor_normal() > Vector2(0.4, -0.8) and get_floor_normal() < Vector2(0.5, -0.9) :
		ground_type = GroundType.SlopeRight
		floor_snap_length = 8
	if get_floor_normal() < Vector2(-0.4, -0.8) and get_floor_normal() > Vector2(-0.5, -0.9) :
		ground_type = GroundType.SlopeLeft
		floor_snap_length = 8
	if get_floor_normal() > Vector2(0.7, -0.7) and get_floor_normal() < Vector2(0.8, -0.8) :
		ground_type = GroundType.SteepRight
		floor_snap_length = 16
	if get_floor_normal() < Vector2(-0.7, -0.7) and get_floor_normal() > Vector2(-0.8, -0.8) :
		ground_type = GroundType.SteepLeft
		floor_snap_length = 16

# Detect slope forces to be applied. Different when player is running.
func check_slope_type() -> void:
	if Input.is_action_pressed("Sprint") or Input.is_action_pressed("Alt_Sprint") :
		match ground_type :
			GroundType.Flat :
				max_speed = 150.0
				slope_boost = 0.0
			GroundType.SlopeRight :
				if direction == 1 :
					max_speed = 175.0
					slope_boost = 1.0
				else :
					max_speed = 125.0
					slope_boost = -0.5
			GroundType.SlopeLeft :
				if direction == -1 :
					max_speed = 175.0
					slope_boost = 1.0
				else :
					max_speed = 125.0
					slope_boost = -0.5
			GroundType.SteepRight :
				if direction == 1 :
					max_speed = 200.0
					slope_boost = 2.0
				else :
					max_speed = 100.0
					slope_boost = -1.0
			GroundType.SteepLeft :
				if direction == -1 :
					max_speed = 200.0
					slope_boost = 2.0
				else :
					max_speed = 100.0
					slope_boost = -1.0
	else :
		match ground_type :
			GroundType.Flat :
				max_speed = 75.0
				slope_boost = 0.0
			GroundType.SlopeRight :
				if direction == 1 :
					max_speed = 90.0
					slope_boost = 1.0
				else :
					max_speed = 60.0
					slope_boost = -0.5
			GroundType.SlopeLeft :
				if direction == -1 :
					max_speed = 90.0
					slope_boost = 1.0
				else :
					max_speed = 60.0
					slope_boost = -0.5
			GroundType.SteepRight :
				if direction == 1 :
					max_speed = 105.0
					slope_boost = 2.0
				else :
					max_speed = 45.0
					slope_boost = -1.0
			GroundType.SteepLeft :
				if direction == -1 :
					max_speed = 105.0
					slope_boost = 2.0
				else :
					max_speed = 45.0
					slope_boost = -1.0

func ground_pound() -> void :
	ground_pound_timer.start()
	AudioManager.play_audio(AudioManager.spin_audio)
	game_state = PlayerState.GroundPound
	animation_sprite.rotation = 0
	var tween = get_tree().create_tween()
	tween.tween_property(animation_sprite, "rotation", deg_to_rad(360 * direction), 0.2).set_ease(Tween.EASE_OUT)
	velocity = Vector2(0, 0)

# Warning : Reading this function may cause permanent brain damage
func player_movement() -> void:
	# Check if raycast is touching the wall for wallslide
	if !is_on_floor() and wall_slide_detector.is_colliding() and velocity.y > 0 :
		game_state = PlayerState.WallSlide
		return
	
	if Input.is_action_pressed("Down") :
		# if you're still and sliding on flat ground, crouch
		if is_on_floor() :
			if velocity.x == 0 and sliding :
				crouching = true
				sliding = false
			# if you're crouching on sloped ground, slide
			elif velocity.x != 0 and ground_type != 0 and crouching :
				crouching = false
				sliding = true
			# if you're on flat ground, crouch
			if ground_type == 0 and !sliding :
				crouching = true
				sliding = false
				deceleration = 4.0
				if is_on_floor():
					velocity.x = move_toward(velocity.x, 0, deceleration)
			# if you're on sloped ground, OR on flat ground but havent slowed down, slide
			elif ground_type != 0 or is_on_floor() and ground_type == 0 and velocity.x != 0:
				crouching = false
				sliding = true
				deceleration = 3.0
				
				# Handle the ammount of speed gained from sliding
				if ground_type == 1 or ground_type == 3 :
					if velocity.x < speed_cap :
						velocity.x += deceleration * (slope_boost * direction)
					else :
						velocity.x -= deceleration * (slope_boost * direction)
						
				elif ground_type == 2 or ground_type == 4 :
					if velocity.x > -speed_cap :
						velocity.x += deceleration * (slope_boost * direction)
					else :
						velocity.x -= deceleration * (slope_boost * direction)
					
				else :
					velocity.x = move_toward(velocity.x, 0, deceleration)
			
	else :
		sliding = false
		crouching = false
		deceleration = 3.0
	
	check_slope_type()
	
	# when sliding dont listen to left or right input
	if !sliding :
		if Input.is_action_pressed("Left") :
			direction = -1
			
			# if crouching, you cant move but can change direction, unless in the air
			if !crouching or crouching and !is_on_floor() :
				if velocity.x > max_speed * direction :
					velocity.x += (acceleration + slope_boost) * direction
				else :
					if velocity.x < speed_cap * direction :
						velocity.x -= (acceleration + slope_boost) * direction
					if Input.is_action_pressed("Sprint") or Input.is_action_pressed("Alt_Sprint") :
						velocity.x += slope_boost * direction
					else :
						velocity.x -= (acceleration + slope_boost) * direction
		
		elif Input.is_action_pressed("Right") :
			direction = 1
			
			# if crouching, you cant move but can change direction, unless in the air
			if !crouching or crouching and !is_on_floor() :
				if velocity.x < max_speed * direction :
					velocity.x += (acceleration + slope_boost) * direction
				else :
					if velocity.x > speed_cap * direction :
						velocity.x -= (acceleration + slope_boost) * direction
					if Input.is_action_pressed("Sprint") or Input.is_action_pressed("Alt_Sprint") :
						velocity.x += slope_boost * direction
					else :
						velocity.x -= (acceleration + slope_boost) * direction
		else :
			# Check if crouching to not slow down twice
			if is_on_floor() and !crouching:
				velocity.x = move_toward(velocity.x, 0, deceleration)
	
	if !jump_delay.is_stopped() and is_on_floor() :
		AudioManager.play_audio(AudioManager.jump_audio)
		
		can_jump = false
		can_cancel_jump = true
		jump_delay.stop()
		
		if velocity.x * direction > 120.0 and !crouching :
			jump_fly = true
		
		if Input.is_action_pressed("Jump"):
			velocity.y = -jump_force - ((velocity.x * direction) * 0.35 if velocity.x * direction > 0 else (velocity.x * direction) * -0.35)
		else :
			velocity.y = -jump_force * 0.4 - ((velocity.x * direction) * 0.35 if velocity.x * direction > 0 else (velocity.x * direction) * -0.35)
	
	if Input.is_action_just_pressed("Down") and !is_on_floor() :
		ground_pound()
	
	if Input.is_action_just_pressed("Jump") :
		if can_jump :
			AudioManager.play_audio(AudioManager.jump_audio)
			# This line stops the player from having a lower jump if going backwards
			velocity.y = -jump_force - ((velocity.x * direction) * 0.35 if velocity.x * direction > 0 else (velocity.x * direction) * -0.35)
			can_cancel_jump = true
			can_jump = false
			# if fast enough change the jump type (For camera)
			if velocity.x * direction > 120.0 and !crouching :
				jump_fly = true
		else :
			jump_delay.start()
	
	elif Input.is_action_just_pressed("Alt_Jump") and !is_on_floor() and game_state == PlayerState.Default :
		if spin_cooldown.is_stopped() :
			AudioManager.play_audio(AudioManager.spin_audio)
			
			crouching = false
			jump_fly = false
			air_spin = true
			
			spin_cooldown.start()
			velocity.y = 0
	
	
	# Change gravity and max falling speed when jump is pressed for better feeling control
	if Input.is_action_pressed("Jump") and velocity.y > 0 :
		gravity = 650.0
		max_fall_speed = 300.0
	else :
		gravity = 850.0
		max_fall_speed = 450.0
	
	# Make sure you can only cancel your jump once per jump
	if Input.is_action_just_released("Jump") and velocity.y < 0 and can_cancel_jump :
		velocity.y *= 0.3
		can_cancel_jump = false

func player_water_movement() -> void:
	max_speed = 75
	acceleration = 3
	
	if Input.is_action_just_released("Alt_Sprint") and carried_body != null :
		drop_body()
		animation_sprite.play("SwimIdle")
	
	if Input.is_action_pressed("Down") :
		gravity = 650
		max_fall_speed = 200
	else :
		gravity = 450
		max_fall_speed = 100
	
	
	if Input.is_action_pressed("Left") :
		direction = -1
		
		if velocity.x > max_speed * direction :
			velocity.x += (acceleration + slope_boost) * direction
		else :
			if velocity.x < speed_cap * direction :
				velocity.x -= (acceleration + slope_boost) * direction
			if Input.is_action_pressed("Sprint") or Input.is_action_pressed("Alt_Sprint") :
				velocity.x += slope_boost * direction
			else :
				velocity.x -= (acceleration + slope_boost) * direction
	
	elif Input.is_action_pressed("Right") :
		direction = 1
		
		if velocity.x < max_speed * direction :
			velocity.x += (acceleration + slope_boost) * direction
		else :
			if velocity.x > speed_cap * direction :
				velocity.x -= (acceleration + slope_boost) * direction
			if Input.is_action_pressed("Sprint") or Input.is_action_pressed("Alt_Sprint") :
				velocity.x += slope_boost * direction
			else :
				velocity.x -= (acceleration + slope_boost) * direction
	else :
		# Check if crouching to not slow down twice
		if is_on_floor() and !crouching:
			velocity.x = move_toward(velocity.x, 0, deceleration)
	
	
	if Input.is_action_just_pressed("Jump") :
		AudioManager.play_audio(AudioManager.swim_audio)
		if water_surface :
			velocity.y = -350
		else :
			velocity.y = -100
		if carried_body == null :
			animation_sprite.play("SwimStroke")
			await animation_sprite.animation_finished
			animation_sprite.play("SwimIdle")
		else :
			animation_sprite.play("SwimStrokeCarry")
			await animation_sprite.animation_finished
			animation_sprite.play("SwimIdleCarry")
	
	


func sword_attack() -> void:
	sword_hitbox.set_deferred("disabled", false)
	animation_sprite.play("SwordSwing")
	# This fixes a bug where if you drop the sword while attacking, the hitbox stays on
	if powerup_state == PlayerState.SwordAttack :
		await animation_sprite.animation_finished
	
	sword_hitbox.set_deferred("disabled", true)
	# Only give sword back if you attacked (Prevents getting sword back when dropping it mid attack)
	if powerup_state == PlayerState.SwordAttack :
		powerup_state = PlayerState.SwordState
	


# Movement with sword ability
func player_sword_movement() -> void:
	if Input.is_action_just_pressed("Alt_Sprint") :
		powerup_state = PlayerState.NP
		AudioManager.play_audio(AudioManager.bounce_audio)
		
		var new = sword_particle.instantiate()
		new.position = position
		add_sibling(new)
		return
	
	if Input.is_action_just_pressed("Sprint") and !air_spin and powerup_state != PlayerState.SwordAttack :
		create_sword_attack_particle()
		sword_hitbox.position.x = 8 * direction
		powerup_state = PlayerState.SwordAttack
		AudioManager.play_audio(AudioManager.stomp_audio)
	
	check_slope_type()
	
	if Input.is_action_pressed("Down") :
		if is_on_floor():
			crouching = true
			deceleration = 4.0
			velocity.x = move_toward(velocity.x, 0, deceleration)
	else :
		crouching = false
		deceleration = 3.0
	
	
	if Input.is_action_pressed("Left") :
		direction = -1
		
		# if crouching on floor, you cant move but can change direction
		if !crouching or crouching and !is_on_floor() :
			if velocity.x > max_speed * direction :
				velocity.x += (acceleration + slope_boost) * direction
			else :
				if velocity.x < speed_cap * direction :
					velocity.x -= (acceleration + slope_boost) * direction
				if Input.is_action_pressed("Sprint") or Input.is_action_pressed("Alt_Sprint") :
					velocity.x += slope_boost * direction
				else :
					velocity.x -= (acceleration + slope_boost) * direction
	
	elif Input.is_action_pressed("Right") :
		direction = 1
		
		# if crouching, you cant move but can change direction
		if !crouching or crouching and !is_on_floor() :
			if velocity.x < max_speed * direction :
				velocity.x += (acceleration + slope_boost) * direction
			else :
				if velocity.x > speed_cap * direction :
					velocity.x -= (acceleration + slope_boost) * direction
				if Input.is_action_pressed("Sprint") or Input.is_action_pressed("Alt_Sprint") :
					velocity.x += slope_boost * direction
				else :
					velocity.x -= (acceleration + slope_boost) * direction
	else :
		# Check if crouching to not slow down twice
		if is_on_floor() and !crouching:
			velocity.x = move_toward(velocity.x, 0, deceleration)

	if !jump_delay.is_stopped() and is_on_floor() :
		AudioManager.play_audio(AudioManager.jump_audio)
		
		can_jump = false
		can_cancel_jump = true
		double_jump = true
		jump_delay.stop()
		
		if velocity.x * direction > 120.0 and !crouching :
			jump_fly = true
		
		if Input.is_action_pressed("Jump"):
			velocity.y = -jump_force - ((velocity.x * direction) * 0.35 if velocity.x * direction > 0 else (velocity.x * direction) * -0.35)
		else :
			velocity.y = -jump_force * 0.4 - ((velocity.x * direction) * 0.35 if velocity.x * direction > 0 else (velocity.x * direction) * -0.35)
	
	if Input.is_action_just_pressed("Jump") :
		if can_jump :
			AudioManager.play_audio(AudioManager.jump_audio)
			# This line stops the player from having a lower jump if going backwards
			velocity.y = -jump_force - ((velocity.x * direction) * 0.35 if velocity.x * direction > 0 else (velocity.x * direction) * -0.35)
			can_cancel_jump = true
			can_jump = false
			# if fast enough change the jump type (For camera)
			if velocity.x * direction > 120.0 and !crouching :
				jump_fly = true
		else :
			jump_delay.start()
	
	elif Input.is_action_just_pressed("Alt_Jump") and !is_on_floor() and powerup_state != PlayerState.SwordAttack :
		if spin_cooldown.is_stopped() :
			powerup_state = PlayerState.SwordState
			AudioManager.play_audio(AudioManager.spin_audio)
			
			crouching = false
			jump_fly = false
			air_spin = true
			
			spin_cooldown.start()
			velocity.y = 0
	
	if Input.is_action_just_pressed("Jump") and !is_on_floor() and double_jump and coyote_time.is_stopped() :
		powerup_state = PlayerState.SwordDJump
		double_jump = false
		AudioManager.play_audio(AudioManager.jump_audio)
		velocity.y = -jump_force - ((velocity.x * direction) * 0.35 if velocity.x * direction > 0 else (velocity.x * direction) * -0.35)
		can_cancel_jump = true
		can_jump = false
		jump_fly = true
	
	# Change gravity and max falling speed when jump is pressed for better feeling control
	if Input.is_action_pressed("Jump") and velocity.y > 0 :
		gravity = 650.0
		max_fall_speed = 300.0
	else :
		gravity = 850.0
		max_fall_speed = 450.0
	
	# Make sure you can only cancel your jump once per jump
	if Input.is_action_just_released("Jump") and velocity.y < 0 and can_cancel_jump :
		velocity.y *= 0.3
		can_cancel_jump = false


# While Carrying, player loses some abilities
func player_carrying_movement() -> void :
	if carried_body == null :
		return
	
	# Player cannot airspin, so set it to false
	air_spin = false
	
	check_slope_type()
	
	# if player stops sprinting drop body
	if Input.is_action_just_released("Alt_Sprint") :
		drop_body()
		return
	
	if Input.is_action_pressed("Down") :
		if is_on_floor():
			crouching = true
			deceleration = 4.0
			velocity.x = move_toward(velocity.x, 0, deceleration)
	else :
		crouching = false
		deceleration = 3.0
	
	if Input.is_action_pressed("Left") :
		direction = -1
		
		if !crouching or crouching and !is_on_floor() :
			if velocity.x > max_speed * direction :
				velocity.x += (acceleration + slope_boost) * direction
			else :
				if velocity.x < speed_cap * direction :
					velocity.x -= (acceleration + slope_boost) * direction
				
				velocity.x += slope_boost * direction
	
	elif Input.is_action_pressed("Right") :
		direction = 1
			
		if !crouching or crouching and !is_on_floor() :
			if velocity.x < max_speed * direction :
				velocity.x += (acceleration + slope_boost) * direction
			else :
				if velocity.x > speed_cap * direction :
					velocity.x -= (acceleration + slope_boost) * direction
				
				velocity.x -= slope_boost * direction
	else :
		if is_on_floor() and !crouching:
			velocity.x = move_toward(velocity.x, 0, deceleration)
	
	
	if !jump_delay.is_stopped() and is_on_floor() :
		AudioManager.play_audio(AudioManager.jump_audio)
		
		can_jump = false
		can_cancel_jump = true
		jump_delay.stop()
		
		if Input.is_action_pressed("Jump"):
			velocity.y = -jump_force - ((velocity.x * direction) * 0.35 if velocity.x * direction > 0 else (velocity.x * direction) * -0.35)
		else :
			velocity.y = -jump_force * 0.5 - ((velocity.x * direction) * 0.35 if velocity.x * direction > 0 else (velocity.x * direction) * -0.35)
	
	if Input.is_action_just_pressed("Jump") :
		if can_jump :
			AudioManager.play_audio(AudioManager.jump_audio)
			
			velocity.y = -jump_force - ((velocity.x * direction) * 0.35 if velocity.x * direction > 0 else (velocity.x * direction) * -0.35)
			can_cancel_jump = true
			can_jump = false
		else :
			jump_delay.start()
	
	if Input.is_action_pressed("Jump") and velocity.y > 0 :
		gravity = 650.0
		max_fall_speed = 300.0
	else :
		gravity = 850.0
		max_fall_speed = 450.0
	
	if Input.is_action_just_released("Jump") and velocity.y < 0 and can_cancel_jump :
		velocity.y *= 0.3
		can_cancel_jump = false
	

func update_body(delta: float) -> void :
	# If no carried body then dont do anything else
	if carried_body == null :
		return
	
	carried_body.velocity = velocity * delta
	carried_body.direction = direction
	carried_body.global_position = position + Vector2(12 * direction, 4)
	
	# If carried body leaves the carryable group at any point drop it
	if !carried_body.is_in_group("Carryable") :
		drop_body()
	

func drop_body() -> void :
	# Set game state to the specified state, allows for other actions to cause dropping body
	carry_delay.start()
	# Place it down
	if Input.is_action_pressed("Down") :
		carried_body.velocity = Vector2(0, 0)
	
	# Kick it up
	elif Input.is_action_pressed("Up") :
		AudioManager.play_audio(AudioManager.stomp_audio)
		carried_body.velocity.y = -jump_force
		carried_body.velocity.x = velocity.x * 0.4
	
	# Kick it forward
	else :
		AudioManager.play_audio(AudioManager.stomp_audio)
		carried_body.velocity = Vector2(125 * direction, -100) + Vector2(velocity.x, 0)
		
	
	carried_body.remove_from_group("Carried")
	carried_body = null

func player_sword_animation() -> void :
	if direction == 1 :
		animation_sprite.flip_h = true
	elif direction == -1 :
		animation_sprite.flip_h = false
	
	if i_frames.is_stopped() :
		animation_sprite.visible = true
		flicker_timer.stop()
	
	if crouching :
		animation_sprite.play("SwordCrouch")

	if air_spin :
		animation_sprite.play("SwordSpin")
		await animation_sprite.animation_finished
		air_spin = false

	# crouching and air spin take priority
	if !crouching and !air_spin :
		if is_on_floor() :
			if velocity.x == 0 :
				if Input.is_action_pressed("Up") :
					animation_sprite.play("SwordUp")
				else :
					animation_sprite.play("SwordIdle")
			elif velocity.x * direction < 0 :
				if Input.is_action_pressed("Left") or Input.is_action_pressed("Right") :
					create_dust()
					if Input.is_action_pressed("Sprint") :
						animation_sprite.play("SwordRunSkid")
					else:
						animation_sprite.play("SwordSkid")
				else :
					animation_sprite.play("SwordWalk")
			else :
				if velocity.x * direction <= 120.0 :
					animation_sprite.play("SwordWalk")
				elif velocity.x * direction > 120.0 :
					animation_sprite.play("SwordRun")
		else :
			if powerup_state == PlayerState.SwordState :
				if jump_fly :
					animation_sprite.play("SwordFly")
				else :
					if velocity.y < 0 :
						animation_sprite.play("SwordJump")
					else :
						animation_sprite.play("SwordFall")
					return
				
			if powerup_state == PlayerState.SwordDJump :
				animation_sprite.play("SwordDJump")
				await animation_sprite.animation_finished
				animation_sprite.play("SwordFly")

func player_carrying_animation() -> void :
	if direction == 1 :
		animation_sprite.flip_h = true
	elif direction == -1 :
		animation_sprite.flip_h = false
	
	if i_frames.is_stopped() :
		animation_sprite.visible = true
		flicker_timer.stop()
	
	if crouching :
		animation_sprite.play("CarryCrouch")
	
	# Crouching animation takes priority
	if !crouching :
		if is_on_floor() :
			if velocity.x == 0 :
				if Input.is_action_pressed("Up") :
					animation_sprite.play("CarryUp")
				else :
					animation_sprite.play("CarryIdle")
			elif velocity.x * direction < 0 :
				if Input.is_action_pressed("Left") or Input.is_action_pressed("Right") :
					create_dust()
				animation_sprite.play("CarryWalk")
			else :
				animation_sprite.play("CarryWalk")
		else :
			animation_sprite.play("CarryJump")
	

func player_animation() -> void :
	if direction == 1 :
		animation_sprite.flip_h = true
	elif direction == -1 :
		animation_sprite.flip_h = false
	
	if i_frames.is_stopped() :
		animation_sprite.visible = true
		flicker_timer.stop()
	
	match game_state :
		PlayerState.Win :
			animation_sprite.play("Win")
		PlayerState.Entering :
			animation_sprite.play("Enter")
		PlayerState.Die :
			animation_sprite.play("Die")
		PlayerState.Stunned :
			animation_sprite.play("Stunned")
		PlayerState.Default :
			if crouching :
				animation_sprite.play("Crouch")
		
			if sliding :
				animation_sprite.play("Slide")
		
			if air_spin :
				animation_sprite.play("AirSpin")
				await animation_sprite.animation_finished
				air_spin = false
		
			# crouching, sliding, and air spin take priority
			if !crouching and !air_spin and !sliding :
				if is_on_floor() :
					if velocity.x == 0 :
						if Input.is_action_pressed("Up") :
							animation_sprite.play("LookUp")
						else :
							animation_sprite.play("Idle")
					elif velocity.x * direction < 0 :
						if Input.is_action_pressed("Left") or Input.is_action_pressed("Right") :
							create_dust()
							if Input.is_action_pressed("Sprint") or Input.is_action_pressed("Alt_Sprint") :
								animation_sprite.play("RunSkid")
							else:
								animation_sprite.play("Skid")
						else :
							animation_sprite.play("Walk")
					else :
						if velocity.x * direction <= 120.0 :
							animation_sprite.play("Walk")
						elif velocity.x * direction > 120.0 :
							animation_sprite.play("Run")
				else :
					if jump_fly :
						animation_sprite.play("Fly")
					else :
						if velocity.y < 0 :
							animation_sprite.play("Jump")
						else :
							animation_sprite.play("Fall")
		
	

func hurt() -> void :
	# check if is hurt already for iframes and all that
	if !is_hurt :
		if GameManager.lives > 0 :
			AudioManager.play_audio(AudioManager.hurt_audio)
			
			if game_state == PlayerState.Default :
				velocity = Vector2(150 * -direction, -150)
			is_hurt = true
			
			i_frames.start()
			flicker_timer.start()
			
			GameManager.remove_lives(1)
		else :
			die()

func die() -> void :
	air_spin = false
	# Disable the Camera so it doesnt track player down
	camera.enabled = false
	
	sword_hitbox.set_deferred("disabled", true)
	
	AudioManager.stop_bgm()
	AudioManager.play_audio(AudioManager.death_audio)
	# Dont let game pause while dying (causes Audio Issues)
	GameManager.can_pause = false
	if GameManager.lives > 0 :
		GameManager.remove_lives(1)
	
	game_state = PlayerState.Die
	hitbox.set_deferred("disabled", true)
	interaction_hitbox.monitoring = false
	velocity = Vector2(0, -jump_force)
	
	death_timer.start()

# Dust particle creator
func create_dust(offset : int = 0) :
	if dust_timer.is_stopped() :
		dust_timer.start()
		AudioManager.play_audio(AudioManager.skid_audio)
		var new_dust = dust_particle.instantiate()
		new_dust.position = position + Vector2(0, 8 + offset)
		add_sibling(new_dust)

func create_sword_attack_particle() :
	var new = sword_attack_particle.instantiate()
	new.direction = direction
	new.position = position + Vector2(8 * direction, 2)
	add_sibling(new)

# Invicibility frames timer
func _on_i_frames_timeout() -> void:
	is_hurt = false

# Sprite flicker timer
func _on_flicker_timer_timeout() -> void:
	if animation_sprite.visible :
		animation_sprite.visible = false
	else :
		animation_sprite.visible = true

# Ammount of time to restart after dying
func _on_death_timer_timeout() -> void:
	if !GameManager.speedrunactive :
		GameManager.fade_in("res://Scenes/Levels/hub_world.tscn")
	else :
		GameManager.fade_in("res://Scenes/Levels/save_room.tscn")
		GameManager.end_speedrun()
	if GameManager.lives <= 0 :
		GameManager.set_lives(3)


func _on_interaction_hitbox_body_entered(body: Node2D) -> void:
		if body.is_in_group("Carryable") and powerup_state == PlayerState.NP and (game_state == PlayerState.Default or game_state == PlayerState.Swim) and carry_delay.is_stopped() :
			if Input.is_action_pressed("Alt_Sprint") and carried_body == null :
				if game_state == PlayerState.Swim :
					animation_sprite.play("SwimIdleCarry")
				carried_body = body
				carried_body.add_to_group("Carried")
			else :
				AudioManager.play_audio(AudioManager.stomp_audio)
				body.velocity = Vector2(75 * direction + velocity.x, -100)


func _on_coyote_time_timeout() -> void:
	can_jump = false


func _on_sword_hitbox_body_entered(body: Node2D) -> void:
	if body == self :
		return
	
	if body.is_in_group("Enemy") :
		if body.has_method("stun") :
			body.stun()
			return
		
		if body.has_method("defeat") :
			body.defeat()
			return


func _on_ground_pound_timer_timeout() -> void:
	if game_state == PlayerState.GroundPound :
		velocity.y = max_fall_speed - 50
		animation_sprite.rotation = deg_to_rad(0)

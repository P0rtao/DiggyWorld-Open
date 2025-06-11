extends CharacterBody2D

@onready var animation_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: CollisionShape2D = $CollisionShape2D
@onready var interaction_hitbox: Area2D = $InteractionHitbox
@onready var on_screen_notifier: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D
@onready var dry_timer: Timer = $DryTimer
@onready var swim_timer: Timer = $SwimTimer
@onready var run_component: Node2D = $RunComponent

var player : Node2D

var can_walk : bool = true
var can_jump_on : bool = true
var dryness : int = 3
var in_water : bool = false


@export var direction : int = -1


func _ready() -> void:
	if on_screen_notifier.is_on_screen() :
		process_mode = PROCESS_MODE_INHERIT
	else :
		process_mode = PROCESS_MODE_DISABLED
	
	player = get_tree().get_first_node_in_group("Player")

func _process(_delta: float) -> void:
	animate()
	
	if in_water :
		dryness = 3
		run_component.gravity = 300
		run_component.max_fall_speed = 150
	else :
		run_component.gravity = 850
		run_component.max_fall_speed = 450
	
	if in_water and swim_timer.is_stopped() :
		swim_timer.start()
		animation_sprite.play("SwimIdle")
		dry_timer.stop()
	
	if !in_water and !swim_timer.is_stopped() :
		swim_timer.stop()
		animation_sprite.play("Walk" + str(dryness))
		dry_timer.start()
	
	match dryness :
		3 : run_component.walkspeed = 100
		2 : run_component.walkspeed = 80
		1 : run_component.walkspeed = 60
	
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
	
	in_water = false
	dry_timer.stop()
	swim_timer.stop()
	can_walk = false

func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	process_mode = PROCESS_MODE_INHERIT


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	if !is_in_group("Enemy") :
		queue_free()
		return
	process_mode = PROCESS_MODE_DISABLED


func _on_dry_timer_timeout() -> void:
	if !in_water and dryness != 0 :
		dryness -= 1
		if dryness > 0 :
			animation_sprite.play("Walk" + str(dryness))
		else :
			defeat()


func _on_swim_timer_timeout() -> void:
	if player.position.y < position.y :
		animation_sprite.play("SwimStroke")
		velocity.y = -120


func _on_interaction_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") :
		body.hurt()


func _on_animated_sprite_2d_animation_finished() -> void:
	animation_sprite.play("SwimIdle")

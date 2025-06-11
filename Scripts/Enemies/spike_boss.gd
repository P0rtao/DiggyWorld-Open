extends CharacterBody2D
signal defeated

var player : Node2D

var health : int = 15

var active : bool = false
var gravity_on : bool = false

var speedx : float = 50.0

var gravity : float = 850.0
var speedy : float = 0.0

@onready var hand_animation: AnimationPlayer = $HandAnimation
@onready var attack_timer: Timer = $AttackTimer

func play_stomp_audio() :
	AudioManager.play_audio(AudioManager.big_stomp_audio)

func _ready() -> void:
	player = get_tree().get_first_node_in_group("Player")

func damage() :
	if health > 0 : 
		health -= 1
		$Face/FaceAnimation.play("Hurt")
	else :
		defeat()
	
	AudioManager.play_audio(AudioManager.stomp_audio)

func defeat() :
	hand_animation.play("Defeat")
	active = false
	$LeftHandHitbox/CollisionShape2D.set_deferred("disabled", true)
	$RightHandHitbox/CollisionShape2D.set_deferred("disabled", true)
	$BodyHitbox/CollisionShape2D.set_deferred("disabled", true)
	attack_timer.stop()
	$FallTimer.start()
	
func _process(delta: float) -> void:
	if active : 
		$LeftHandHitbox/CollisionShape2D.position = $LeftHand.position
		$RightHandHitbox/CollisionShape2D.position = $RightHand.position
		if player.position.x > position.x :
			velocity.x += speedx * delta
			if velocity.x < 0 :
				velocity.x += (speedx * 3) * delta
		else :
			velocity.x -= speedx * delta
			if velocity.x > 0 :
				velocity.x -= (speedx * 3) * delta
		move_and_slide()
	
	if gravity_on :
		speedy += gravity * delta
		position.y += speedy * delta
	
func start_attack_timer() :
	attack_timer.start()

func _on_left_hand_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") :
		$Face/FaceAnimation.play("Laugh")
		body.hurt()


func _on_right_hand_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") :
		$Face/FaceAnimation.play("Laugh")
		body.hurt()


func _on_attack_timer_timeout() -> void:
	var selected_attack : int = randi_range(1, 3)
	
	match selected_attack :
		1 : hand_animation.play("HandSlam")
		2 : hand_animation.play("HandSlamCenter")
		3 : hand_animation.play("HandSweep")
	
	if health > 5 :
		attack_timer.wait_time = randi_range(1, 4)
	else :
		speedx = 90
		attack_timer.wait_time = randf_range(0.5, 2.0)


func _on_body_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("Bullet") :
		damage()
		area.queue_free()


func _on_fall_timer_timeout() -> void:
	gravity_on = true
	defeated.emit()

extends StaticBody2D

@onready var animation_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var bounce_time: Timer = $BounceTimer

var og_pos : float
var bounce_speed : float = -100
var speed : float = 0
var gravity : float = 850
var hit : bool = false

func _ready() -> void :
	og_pos = animation_sprite.position.y

func _process(delta: float) -> void :
	if bounce_time.is_stopped() :
		animation_sprite.position.y = og_pos
	else :
		animation_sprite.position.y += speed * delta
		speed += gravity * delta

func update_block_state() -> void :
	if is_in_group("BlockON") :
		animation_sprite.play("ON")
	
	if is_in_group("BlockOFF") :
		animation_sprite.play("OFF")

func bounce() -> void :
	var on_array : Array
	var off_array : Array
	
	AudioManager.play_audio(AudioManager.bounce_audio)
	
	bounce_time.start()
	
	animation_sprite.position.y = og_pos
	speed = bounce_speed
	hit = true
	
	# Seperate ON and OFF blocks
	for i in get_tree().get_nodes_in_group("BlockON") :
		on_array.append(i)
	
	for i in get_tree().get_nodes_in_group("BlockOFF") :
		off_array.append(i)
	
	# Switch Block States
	for i in on_array :
		i.remove_from_group("BlockON")
		i.add_to_group("BlockOFF")
		i.update_block_state()
	
	for i in off_array :
		i.remove_from_group("BlockOFF")
		i.add_to_group("BlockON")
		i.update_block_state()

func _on_area_2d_body_entered(body) -> void:
	if not hit :
		if body.is_in_group("Player") or body.is_in_group("Carryable") :
			bounce()


func _on_bounce_timer_timeout() -> void:
	hit = false

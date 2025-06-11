extends Area2D

@export var castle: bool = false
@export var required : int
@export var target_level : String
var open : bool
var player : Node2D

@onready var number_display: Node2D = $NumberDisplay
@onready var animation_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var load_level_timer: Timer = $LoadLevelTimer

func _ready() -> void:
	number_display.set_number(required)
	
	if castle :
		animation_sprite.play("Castle")
		animation_sprite.offset.y = -32
	else :
		animation_sprite.play("House")
	
	if GameManager.golden_bones >= required :
		animation_sprite.set_frame_and_progress(1, 0)
		open = true
	else :
		animation_sprite.set_frame_and_progress(0, 0)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("Up") and player != null and open and load_level_timer.is_stopped():
		load_level_timer.start()
		GameManager.save_last_pos(position)
		player.velocity = Vector2(0, 0)
		player.game_state = player.PlayerState.Entering
		player.position = position

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") :
		player = body


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player") :
		player = null


func _on_load_level_timer_timeout() -> void:
	GameManager.fade_in(target_level)

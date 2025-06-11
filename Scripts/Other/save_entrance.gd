extends Area2D

@export var save_slot : int
var player : Node2D

@onready var number_display: Node2D = $NumberDisplay
@onready var load_save_timer: Timer = $LoadSaveTimer

func _ready() -> void:
	number_display.set_number(save_slot)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("Up") and player != null and load_save_timer.is_stopped() :
		load_save_timer.start()
		
		player.velocity = Vector2(0, 0)
		player.game_state = player.PlayerState.Entering
		player.position = position
		
		GameManager.load_save_slot(save_slot)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") :
		player = body


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player") :
		player = null


func _on_load_save_timer_timeout() -> void:
	GameManager.fade_in("res://Scenes/Levels/hub_world.tscn")

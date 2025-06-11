extends Area2D

var player : Node2D

@onready var load_timer: Timer = $LoadTimer

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("Up") and player != null and load_timer.is_stopped() :
		load_timer.start()
		
		player.velocity = Vector2(0, 0)
		player.game_state = player.PlayerState.Entering
		player.position = position
		
		GameManager.load_save_slot(0)
		GameManager.start_speedrun()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") :
		player = body


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player") :
		player = null


func _on_load_timer_timeout() -> void:
	GameManager.fade_in("res://Scenes/Levels/grass_1.tscn")

extends Node2D

func _ready() -> void:
	GameManager.fade_out(false)
	AudioManager.start_bgm("Credits")
	
	var tween = get_tree().create_tween()
	tween.tween_property($CreditsText, "position", Vector2(0, -1000), 80)

func _process(delta: float) -> void:
	$ParallaxBackground.scroll_base_offset += Vector2(100 * delta, 0)

func _input(_event: InputEvent) -> void :
	if Input.is_action_just_pressed("ui_accept") :
		GameManager.fade_in("res://Scenes/Levels/save_room.tscn")

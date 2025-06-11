extends Node2D

@onready var boss_start_timer: Timer = $BossStartTimer
@onready var boss_end_timer: Timer = $BossEndTimer
var boss_scene : PackedScene = preload("res://Scenes/BossFight/potao_boss.tscn")

func _on_start_trigger_start_boss() -> void:
	boss_start_timer.start()


func _on_boss_start_timer_timeout() -> void:
	var boss = boss_scene.instantiate()
	boss.position = Vector2(1450, -280)
	AudioManager.start_bgm("Boss")
	add_child(boss)


func _on_bottom_limit_body_entered(body: Node2D) -> void:
	if body.is_in_group("Boss") :
		var camera = get_tree().get_first_node_in_group("Camera")
		camera.cam_shake()
		AudioManager.play_audio(AudioManager.big_stomp_audio)
		boss_end_timer.start()


func _on_boss_end_timer_timeout() -> void:
	var camera = get_tree().get_first_node_in_group("Camera")
	var player = get_tree().get_first_node_in_group("Player")
	if player.carried_body != null :
		player.drop_body()
	camera.enabled = true
	camera.set_cam_pos(player.position)
	AudioManager.stop_bgm()
	queue_free()

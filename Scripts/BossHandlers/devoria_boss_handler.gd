extends Node2D

var player : Node2D
var camera : Node2D

func _ready() -> void:
	player = get_tree().get_first_node_in_group("Player")
	camera = get_tree().get_first_node_in_group("Camera")

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") :
		$BossStartTrigger.queue_free()
		camera.enabled = false
		camera.set_cam_pos(Vector2(12260, 180))
		$LimitLeft/CollisionShape2D.set_deferred("disabled", false)
		AudioManager.start_bgm("FinalBoss")
		$BossStartTimer.start()


func _on_boss_start_timer_timeout() -> void:
	$FinalBoss.active = true


func _on_final_boss_boss_defeated() -> void:
	AudioManager.stop_bgm()
	camera.set_cam_pos(player.position)
	camera.enabled = true
	$LimitRight.queue_free()
	$LimitLeft.queue_free()

extends Node2D

var camera : Node2D
var player : Node2D

@onready var zombie_boss: CharacterBody2D = $ZombieBoss
@onready var cam_to_boss_timer: Timer = $CamToBossTimer
@onready var boss_start_timer: Timer = $BossStartTimer
@onready var boss_end_timer: Timer = $BossEndTimer

func _ready() -> void:
	camera = get_tree().get_first_node_in_group("Camera")
	player = get_tree().get_first_node_in_group("Player")

func move_camera(enabled : bool = true, pos : Vector2 = Vector2(0, 0)) -> void:
	camera.enabled = enabled
	camera.set_cam_pos(pos)

func _on_boss_start_trigger_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") :
		body.velocity = Vector2(0, 0)
		body.can_move = false
		$BossStartTrigger.queue_free()
		zombie_boss.enable()
		cam_to_boss_timer.start()
		AudioManager.play_audio(AudioManager.big_stomp_audio)
		camera.cam_shake()


func _on_cam_to_boss_timer_timeout() -> void:
	camera.enabled = false
	camera.set_cam_pos(zombie_boss.position)
	boss_start_timer.start()

func _on_boss_start_timer_timeout() -> void:
	camera.set_cam_pos(player.position)
	camera.enabled = true
	AudioManager.start_bgm("Boss")
	player.can_move = true


func _on_boss_death_trigger_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") :
		zombie_boss.dead = true
		boss_end_timer.start()
		$BossDeathTrigger.queue_free()


func _on_boss_end_timer_timeout() -> void:
	zombie_boss.queue_free()
	AudioManager.play_audio(AudioManager.big_stomp_audio)
	camera.cam_shake()
	AudioManager.stop_bgm()
	$GoldenBoneAnimation.play("GoldenBoneLower")

extends Node2D
var particle : PackedScene = preload("res://Scenes/Other/brick_break_particle.tscn")

var camera : Node2D
var player : Node2D

@onready var cutscene_start_timer: Timer = $CutsceneStartTimer

func _ready() -> void:
	camera = get_tree().get_first_node_in_group("Camera")
	player = get_tree().get_first_node_in_group("Player")

func spawn_particle(pos : Vector2) :
	var new = particle.instantiate()
	new.position = pos
	add_child(new)

func move_camera(enabled : bool = true, pos : Vector2 = Vector2(0, 0)) -> void:
	camera.enabled = enabled
	camera.set_cam_pos(pos)

func shake_cam_cutscene() -> void :
	camera.cam_shake(false)
	AudioManager.play_audio(AudioManager.big_stomp_audio)

func stun_player() -> void :
	player.game_state = player.PlayerState.Stunned
func unstun_player() -> void :
	player.game_state = player.PlayerState.Default

func _on_cutscene_trigger_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") :
		cutscene_start_timer.start()
		player.can_move = false
		player.velocity = Vector2(0, 0)
		player.crouching = false
		$CutsceneTrigger.queue_free()

func start_boss() -> void :
	AudioManager.start_bgm("Boss")
	player.can_move = true
	camera.set_cam_limit(0, 216, 960, 1500)
	move_camera(true, player.position)
	$SpikeBoss.active = true
	$SpikeBoss.hand_animation.play("HandSway")
	$SpikeBoss.attack_timer.start()
	$LimitLeft/CollisionShape2D.disabled = false

func _on_cutscene_start_timer_timeout() -> void:
	$CutsceneAnimPlayer.play("HauntedBossCutscene")
	move_camera(false, Vector2(1250, 0))


func _on_spike_boss_defeated() -> void:
	camera.set_cam_limit(0, 216, 0, 1968)
	camera.set_cam_pos(player.position)
	AudioManager.stop_bgm()
	$BossEndTimer.start()
	$LimitRight.queue_free()
	$LimitLeft.queue_free()


func _on_boss_end_timer_timeout() -> void:
	queue_free()

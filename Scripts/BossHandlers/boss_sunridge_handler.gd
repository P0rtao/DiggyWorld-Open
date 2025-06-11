extends Node2D
var particle : PackedScene = preload("res://Scenes/Other/cube_particle.tscn")

var boss : PackedScene = preload("res://Scenes/BossFight/skeleton_boss.tscn")

@onready var boss_start_timer: Timer = $BossStartTimer
@onready var boss_stop_timer: Timer = $BossStopTimer

var player : Node2D
var camera: Node2D

func _ready() -> void:
	player = get_tree().get_first_node_in_group("Player")
	camera = get_tree().get_first_node_in_group("Camera")

func end_boss() -> void :
	boss_stop_timer.start()

func _on_start_trigger_start_boss() -> void:
	AudioManager.play_audio(AudioManager.collect_audio)
	boss_start_timer.start()
	
	var new = particle.instantiate()
	new.position = $StartTrigger.position
	add_sibling(new)


func _on_boss_start_timer_timeout() -> void:
	AudioManager.start_bgm("Boss")
	
	var new = boss.instantiate()
	new.position = Vector2(1343, 172)
	add_child(new)


func _on_boss_stop_timer_timeout() -> void:
	AudioManager.stop_bgm()
	camera.enabled = true
	camera.set_cam_pos(player.position)
	$LimitLeft.queue_free()
	$LimitRight.queue_free()
	$BottomLimit.queue_free()
	$CameraSwitch.queue_free()

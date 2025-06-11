extends Area2D

var camera : Node2D
@onready var lava: TileMapLayer = $"../Lava"
@onready var door: TileMapLayer = $"../Door"

func _ready() -> void:
	camera = get_tree().get_first_node_in_group("Camera")

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") :
		AudioManager.stop_bgm()
		AudioManager.play_audio(AudioManager.big_stomp_audio)
		
		camera.stop_cam_shake()
		door.enabled = true
		
		queue_free()

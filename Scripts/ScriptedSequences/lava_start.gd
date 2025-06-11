extends Area2D

var camera : Node2D
@onready var lava: TileMapLayer = $"../Lava"

func _ready() -> void:
	camera = get_tree().get_first_node_in_group("Camera")

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") :
		AudioManager.start_bgm("Lava")
		
		camera.cam_shake(true)
		
		var tween = get_tree().create_tween()
		tween.tween_property(lava, "position", Vector2(0, -500), 40)
		
		queue_free()

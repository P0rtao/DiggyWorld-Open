extends Area2D

@export var enable : bool = false
@export var cam_position : Vector2
@export var zoom: int = 3
var camera: Node2D

func _ready() -> void:
	camera = get_tree().get_first_node_in_group("Camera")

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") :
		camera.enabled = enable
		camera.set_cam_pos(cam_position, zoom)

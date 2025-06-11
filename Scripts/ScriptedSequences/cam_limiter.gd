extends Area2D

var camera : Node2D

@export var top : int = 0
@export var bottom : int = 0
@export var left : int = 0
@export var right : int = 0

func _ready() -> void:
	camera = get_tree().get_first_node_in_group("Camera")

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") :
		camera.set_cam_limit(top, bottom, left, right)

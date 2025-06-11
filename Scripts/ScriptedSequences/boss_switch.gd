extends Area2D
signal start_boss

@export var cam_position : Vector2
@export var zoom: int = 3
var camera: Node2D

@onready var left_limit: CollisionShape2D = $"../LimitLeft/CollisionShape2D"
@onready var right_limit: CollisionShape2D = $"../LimitRight/CollisionShape2D"
@onready var bottom_limit: CollisionShape2D = $"../BottomLimit/CollisionShape2D"

func _ready() -> void:
	camera = get_tree().get_first_node_in_group("Camera")

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") :
		start_boss.emit()
		
		camera.enabled = false
		camera.set_cam_pos(cam_position, zoom)
		
		left_limit.set_deferred("disabled", false)
		right_limit.set_deferred("disabled", false)
		bottom_limit.set_deferred("disabled", false)
		
		queue_free()

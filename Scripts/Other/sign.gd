@tool
extends AnimatedSprite2D

@export var type : int = 0
@export var flip : bool = false


func _ready() -> void:
	set_frame_and_progress(type, 0)
	flip_h = flip

func _process(_delta: float) -> void:
	# This only runs in the editor
	if Engine.is_editor_hint():
		set_frame_and_progress(type, 0)
		flip_h = flip

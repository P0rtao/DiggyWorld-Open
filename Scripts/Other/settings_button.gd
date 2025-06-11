extends StaticBody2D

var content : PackedScene
var ammount : int = 0
var start_ammount : int = 0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

@export var value : float
@export var setting : String

func _ready() -> void:
	# Set sprite frames so button makes sense
	if setting == "Resolution" :
		if value == 0 :
			sprite.set_frame_and_progress(3, 0)
		else :
			sprite.set_frame_and_progress(2, 0)
	else :
		if value < 0 :
			sprite.set_frame_and_progress(0, 0)
		else :
			sprite.set_frame_and_progress(1, 0)


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") :
		GameManager.change_setting(setting, value)
		GameManager.save_settings()

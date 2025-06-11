extends AnimatedSprite2D
@onready var number_display: Node2D = $NumberDisplay


@export var setting : String = "Master"

func _ready() -> void:
	match setting :
		"Master" :
			set_frame_and_progress(0, 0)
		"Music" :
			set_frame_and_progress(1, 0)
		"Sound" :
			set_frame_and_progress(2, 0)

func _process(_delta: float) -> void:
	match setting :
		"Master" :
			number_display.set_number(GameManager.master_volume * 100)
		"Music" :
			number_display.set_number(GameManager.music_volume * 100)
		"Sound" :
			number_display.set_number(GameManager.sfx_volume * 100)

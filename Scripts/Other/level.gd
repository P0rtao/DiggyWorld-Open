extends Node2D

@export var hub : bool
@export var show_ui : bool = true
@export var cam_limit_right : int
@export var cam_limit_up : int
@export var cam_limit_left : int
@export var cam_limit_down : int

@export var song_name : String = ""

@onready var camera: Node2D = $Camera
@onready var player: Node2D = $Player

func _ready() -> void:
	GameManager.can_pause = true
	
	if song_name != "" :
		AudioManager.start_bgm(song_name)
	else :
		AudioManager.stop_bgm()
	
	if hub and GameManager.last_position :
		player.position = GameManager.last_position
	
	
	camera.set_cam_limit(cam_limit_up, cam_limit_down, cam_limit_left, cam_limit_right)
	
	GameManager.fade_out(show_ui)

extends Node2D

@onready var camera: Camera2D = $Camera2D
@onready var player: Node2D = $"../Player"
@onready var smooth_timer: Timer = $SmoothTimer
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var cam_direction: int = 0
var hoffset: float = 0
var offset_speed : int = 150
var track_vertical : bool = false
var voffset: int = 140

@export var enabled : bool = true

func _ready() -> void:
	if enabled :
		position = player.position + Vector2(0, -16)

func _process(delta: float) -> void:
	if enabled :
		update_camera_horizontal(delta)
		update_camera_vertical(delta)

func set_cam_limit(top: int, bottom: int, left: int, right: int) -> void :
	camera.limit_left = left
	
	if top <= 0 :
		camera.limit_top = top
		
	if bottom != 0 :
		camera.limit_bottom = bottom
		
	if right != 0 :
		camera.limit_right = right

func set_cam_pos(pos: Vector2, zoom: int = 3) -> void :
	smooth_timer.stop()
	camera.zoom = Vector2(zoom, zoom)
	camera.position_smoothing_enabled = true
	position = pos
	smooth_timer.start()

func update_camera_horizontal(_delta: float) -> void :
	# Check if the player is more to the left or to the right
	if player.position.x > position.x + 36 :
		cam_direction = 1
	if player.position.x < position.x - 36 :
		cam_direction = -1
	
	# These two just make sure the camera only follows the player if the way it's going matches the direction
	if player.position.x > position.x - hoffset and cam_direction == 1 :
		position.x = player.position.x + hoffset
	
	if player.position.x < position.x - hoffset and cam_direction == -1 :
		position.x = player.position.x + hoffset
	
	# Tween the hoffset to the final position
	if hoffset * cam_direction < 32 :
		var tween = get_tree().create_tween()
		tween.tween_property(self, "hoffset", 32 * cam_direction, 0.25).set_ease(Tween.EASE_IN_OUT)
	else :
		hoffset = 32 * cam_direction

func update_camera_vertical(delta: float) -> void :
	# Always follow if player is falling down
	if player.position.y > position.y + 16 :
		position.y = player.position.y - 16
	
	
	if player.position.y < position.y - 32 :
		if player.is_on_floor() :
			track_vertical = true
		if player.jump_fly :
			position.y = player.position.y + 32
	else :
		if !player.is_on_floor() :
			track_vertical = false
	
	if track_vertical :
		position.y -= voffset * delta

func cam_shake(repeat: bool = false) -> void :
	if repeat :
		animation_player.play("CamShakeRepeat")
	else :
		animation_player.play("CamShake")

func stop_cam_shake() -> void :
	animation_player.stop()
	camera.offset = Vector2(0, 0)

func _on_smooth_timer_timeout() -> void:
	camera.position_smoothing_enabled = false

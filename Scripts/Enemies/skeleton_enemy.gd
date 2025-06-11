extends CharacterBody2D
var particle : PackedScene = preload("res://Scenes/Other/bones_particle.tscn")

@onready var animation_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var on_screen_notifier: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D


var can_walk : bool = true
var can_jump_on : bool = true
var in_water : bool = false

@export var direction : int = -1

func _ready() -> void :
	if on_screen_notifier.is_on_screen() :
		process_mode = PROCESS_MODE_INHERIT
	else :
		process_mode = PROCESS_MODE_DISABLED

func _process(_delta: float) -> void :
	animate()
	
	move_and_slide()

func animate() -> void :
	if direction == 1 :
		animation_sprite.flip_h = true
	else :
		animation_sprite.flip_h = false

func defeat() -> void :
	AudioManager.play_audio(AudioManager.stomp_audio)
	
	var new = particle.instantiate()
	new.position = position
	add_sibling(new)
	
	queue_free()

func _on_on_jump_component_jumped_on() -> void:
	defeat()


func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	process_mode = PROCESS_MODE_INHERIT


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	process_mode = PROCESS_MODE_DISABLED


func _on_on_ground_pound_component_ground_pound_on() -> void:
	defeat()

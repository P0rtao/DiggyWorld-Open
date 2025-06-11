extends Node2D

var explosion : PackedScene = preload("res://Scenes/Other/explosion.tscn")

@onready var vis_notif: VisibleOnScreenNotifier2D = $"../VisibleOnScreenNotifier2D"
@onready var sprite_2d: AnimatedSprite2D = $"../Sprite2D"


func _ready() -> void:
	if !vis_notif.is_on_screen() :
		owner.process_mode = Node.PROCESS_MODE_DISABLED
		return

func explode() -> void:
	var new = explosion.instantiate()
	new.position = owner.position
	owner.call_deferred("add_sibling", new)
	
	owner.queue_free()

func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	owner.process_mode = Node.PROCESS_MODE_INHERIT


func _on_animated_sprite_2d_animation_finished() -> void:
	explode()


func _on_interaction_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("Enemy") or body.is_in_group("Boss") :
		explode()

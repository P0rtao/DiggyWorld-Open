extends CharacterBody2D

var direction : int = 1
var can_walk : bool = false
var inwall : bool = false
@onready var sprite_2d: Node2D = $Sprite2D
@onready var interaction_hitbox: Area2D = $InteractionHitbox

@onready var hitbox: CollisionShape2D = $CollisionShape2D


func _process(_delta: float) -> void :
	animate()
	
	match is_in_group("Carried") :
		true :
			hitbox.set_deferred("disabled", true)
		false :
			hitbox.set_deferred("disabled", false)
			in_wall()
			
	
	if !is_in_group("Carried") :
		move_and_slide()

func animate() -> void :
	if direction < 0 :
		sprite_2d.flip_h = true
	else :
		sprite_2d.flip_h = false

func in_wall() -> void :
	if inwall :
		position.x -= 16 * direction

func _on_interaction_hitbox_body_entered(body: Node2D) -> void:
	if body is TileMapLayer or body.is_in_group("Barrier") :
		inwall = true


func _on_interaction_hitbox_body_exited(body: Node2D) -> void:
	if body is TileMapLayer or body.is_in_group("Barrier") :
		inwall = false

extends Node2D

@export var offset : float = 8.0
@export var enabled : bool = true

@onready var hitbox: CollisionShape2D = $Area2D/CollisionShape2D

func _process(_delta: float) -> void:
	hitbox.position.x = offset * owner.direction

func _on_sword_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") and enabled :
		AudioManager.play_audio(AudioManager.big_stomp_audio)
		body.hurt()
		owner.can_walk = false
		owner.animation_sprite.play("Attack")
		hitbox.set_deferred("disabled", true)
		await owner.animation_sprite.animation_finished
		owner.can_walk = true
		owner.animation_sprite.play("Walk")
		hitbox.set_deferred("disabled", false)

extends Node

signal ground_pound_on
@export var bounce_height : float = 330


func _on_interaction_hitbox_body_entered(body: Node2D) -> void:
	if owner.can_jump_on :
		if body.is_in_group("Player") :
			if body.velocity.y > 0 and body.game_state == body.PlayerState.GroundPound :
				ground_pound_on.emit()

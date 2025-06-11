extends Node

signal jumped_on
@export var bounce_height : float = 330


func _on_interaction_hitbox_body_entered(body: Node2D) -> void:
	if owner.can_jump_on :
		if body.is_in_group("Player") :
			if body.velocity.y > 0 and body.game_state == body.PlayerState.Default or body.game_state == body.PlayerState.RampJump :
				jumped_on.emit()
				if Input.is_action_pressed("Jump") :
					body.velocity.y = -bounce_height
				else :
					body.velocity.y = -bounce_height * 0.5

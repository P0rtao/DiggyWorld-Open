extends StaticBody2D

@export var direction : int = 1

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var collision_shape_2d: CollisionPolygon2D = $CollisionShape2D

func _ready() -> void:
	$Area2D/CollisionShape2D.position.x = 18 * direction
	if direction == 1 :
		sprite_2d.flip_h = true
		collision_shape_2d.scale.x = -1
	else :
		sprite_2d.flip_h = false
		collision_shape_2d.scale.x = 1

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") :
		if body.carried_body != null :
			if direction == 1 :
				if body.velocity.x >= 140 and body.velocity.x < 240 :
					body.position.y -= 4
					body.velocity.y = -400
					body.velocity.x += 50
			else :
				if body.velocity.x <= -140 and body.velocity.x > -240 :
					body.position.y -= 4
					body.velocity.y = -400
					body.velocity.x -= 50
			return
		
		if direction == 1 :
			if body.velocity.x >= 140 and body.velocity.x < 240 :
				body.position.y -= 4
				body.velocity.y = -400
				body.velocity.x += 50
				body.game_state = body.PlayerState.RampJump
			elif body.velocity.x >= 240 :
				body.position.y -= 4
				body.velocity.y = -500
				body.velocity.x += 100
				body.game_state = body.PlayerState.RampJump
		else :
			if body.velocity.x <= -140 and body.velocity.x > -240 :
				body.position.y -= 4
				body.velocity.y = -400
				body.velocity.x -= 50
				body.game_state = body.PlayerState.RampJump
			elif body.velocity.x <= -240 :
				body.position.y -= 4
				body.velocity.y = -500
				body.velocity.x -= 100
				body.game_state = body.PlayerState.RampJump

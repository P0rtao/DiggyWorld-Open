extends Sprite2D

var direction : int = 1
var speed : float = 75.0

func _process(delta: float) -> void:
	if direction > 0 :
		flip_h = false
	if direction < 0 :
		flip_h = true
	
	position.x += (speed * direction) * delta


func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	queue_free()

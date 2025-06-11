extends Sprite2D

var object : PackedScene = preload("res://Scenes/Entities/bomb.tscn")

func _on_timer_timeout() -> void:
	
	if get_child_count() > 1 :
		return
	
	var new = object.instantiate()
	new.position = Vector2(0, 0)
	add_child(new)

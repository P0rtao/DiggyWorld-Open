extends ParallaxBackground

func _process(delta: float) -> void:
	scroll_base_offset.x += -50 * delta

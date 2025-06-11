extends PointLight2D

func _process(_delta: float) -> void:
	position.x = 48 * owner.direction
	
	if owner.is_in_group("Carried") :
		self.texture_scale = 2
	else :
		self.texture_scale = 1

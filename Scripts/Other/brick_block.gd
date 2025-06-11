extends StaticBody2D

var particle : PackedScene = preload("res://Scenes/Other/brick_break_particle.tscn")
var in_water : bool = true

func destroy_brick() :
	var new = particle.instantiate()
	new.position = position
	call_deferred("add_sibling", new)
	
	queue_free()

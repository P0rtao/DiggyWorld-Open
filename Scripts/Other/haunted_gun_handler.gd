extends Node2D

var bullet_scene : PackedScene = preload("res://Scenes/Other/haunted_bullet.tscn")

func _process(_delta: float) -> void:
	if owner.is_in_group("Carried") : 
		if $ShootTimer.is_stopped() :
			$ShootTimer.start()
	else :
		$ShootTimer.stop()


func _on_shoot_timer_timeout() -> void:
	var new = bullet_scene.instantiate()
	new.speed = owner.direction * 300
	new.position = owner.position + Vector2(4 * owner.direction, 0)
	owner.add_sibling(new)

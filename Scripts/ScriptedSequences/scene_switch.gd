extends Area2D

@export var target : String

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") :
		GameManager.fade_in(target)

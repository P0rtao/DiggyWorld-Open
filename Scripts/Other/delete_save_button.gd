extends StaticBody2D

var content : PackedScene
var ammount : int = 0
var start_ammount : int = 0

@export var save_slot : int = 0

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") :
		GameManager.delete_save_slot(save_slot)

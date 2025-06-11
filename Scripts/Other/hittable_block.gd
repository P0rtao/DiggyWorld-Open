extends StaticBody2D


@export var content : PackedScene
@export var ammount : int
var start_ammount : int

func _ready() -> void :
	start_ammount = ammount

func bounce() -> void :
	$HittableComponent.bounce()

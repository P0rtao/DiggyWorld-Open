extends ParallaxBackground

@export var replace : bool = false

func _ready() -> void:
	if GameManager.golden_bone_dict["Devoria"] == true or !replace :
		$ParallaxLayer4.queue_free()
	else :
		$ParallaxLayer2.queue_free()
		$ParallaxLayer3.queue_free()

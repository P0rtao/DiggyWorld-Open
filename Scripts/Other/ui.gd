extends CanvasLayer

@onready var bone_display: Node2D = $BoneDisplay
@onready var life_display: Node2D = $LifeDisplay
@onready var g_bone_display: Node2D = $GBoneDisplay

func _ready() -> void:
	bone_display.set_number(GameManager.bones)
	life_display.set_number(GameManager.lives)
	g_bone_display.set_number(GameManager.golden_bones)

func update_bones(bone_num: int) -> void:
	bone_display.set_number(bone_num)

func update_lives(life_num: int) -> void:
	life_display.set_number(life_num)

func update_gbones(g_num: int) -> void :
	g_bone_display.set_number(g_num)

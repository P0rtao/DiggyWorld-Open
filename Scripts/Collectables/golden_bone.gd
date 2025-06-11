extends Area2D

var particle : PackedScene = preload("res://Scenes/Other/golden_bone_particle.tscn")
@export var bone_name : String
@export var song_type: String = "Grass"

@onready var animation_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: CollisionShape2D = $CollisionShape2D
@onready var change_scene_timer: Timer = $ChangeSceneTimer
@export var target_scene : String = "res://Scenes/Levels/hub_world.tscn"

@export var target_speedrun : String = "res://Scenes/Levels/hub_world.tscn"
@export var stop_speedrun : bool = false

func _on_body_entered(body) -> void:
	if body.is_in_group("Player") :
		change_scene_timer.start()
		
		var newparticle = particle.instantiate()
		newparticle.position = position
		add_sibling(newparticle)
		
		GameManager.add_golden_bone(bone_name)
		GameManager.can_pause = false
		
		AudioManager.golden_bone_audio(song_type)
		AudioManager.stop_bgm()
		
		body.game_state = body.PlayerState.Win
		hitbox.set_deferred("Disabled", true)
		position = body.position + Vector2(0, -24)
		
		if !GameManager.speedrunactive :
			GameManager.save_save_slot(GameManager.loaded_slot)
		
		if stop_speedrun :
			GameManager.speedrun_timer.stop()


func _on_change_scene_timer_timeout() -> void:
	if GameManager.speedrunactive :
		GameManager.fade_in(target_speedrun)
		if stop_speedrun :
			GameManager.end_speedrun(true)
	else :
		GameManager.fade_in(target_scene)

extends CanvasLayer
@onready var pause_debounce: Timer = $PauseDebounce

var can_unpause : bool = true

func _ready() -> void:
	visible = false

func _process(_delta: float) -> void:
	match get_tree().paused :
		true :
			if Input.is_action_just_pressed("Jump") :
				if GameManager.speedrunactive :
					GameManager.fade_in("res://Scenes/Levels/save_room.tscn")
					GameManager.end_speedrun()
				else :
					GameManager.fade_in("res://Scenes/Levels/hub_world.tscn")
				can_unpause = false
				visible = false
			
			if Input.is_action_just_pressed("Sprint") :
				get_tree().quit()
			
			if Input.is_action_just_pressed("ui_accept") and pause_debounce.is_stopped() and can_unpause :
				visible = false
				get_tree().paused = false
		false :
			if Input.is_action_just_pressed("ui_accept") and GameManager.can_pause :
				get_tree().paused = true
				visible = true
				debounce()
	
func debounce() -> void:
	pause_debounce.start()
	

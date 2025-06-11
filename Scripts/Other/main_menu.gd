extends Node2D

@onready var hub_background: ParallaxBackground = $HubBackground
@onready var start_button: AnimatedSprite2D = $StartButton
@onready var controls_button: AnimatedSprite2D = $ControlsButton
@onready var quit_button: AnimatedSprite2D = $QuitButton
@onready var rebind_label: AnimatedSprite2D = $RebindLabel
@onready var key_rebinding: AnimatedSprite2D = $RebindLabel/KeyRebinding

var selected : int = 0
# 0 = Start
# 1 = Controls
var selection : Array

var rebinding : bool = false
var to_rebind : int = 0

func _ready() -> void:
	GameManager.fade_out(false)
	AudioManager.start_bgm("MainMenu")
	selection.append(start_button)
	selection.append(controls_button)
	selection.append(quit_button)
	set_process_unhandled_input(false)
	update_selection()

func _process(delta: float) -> void:
	hub_background.scroll_base_offset.x += -75 * delta
	match rebinding :
		false :
			if Input.is_action_just_pressed("ui_up") :
				selected -= 1
				if selected > 2 :
					selected = 0
				
				if selected < 0 :
					selected = 2
				AudioManager.play_audio(AudioManager.collect_audio)
				update_selection()
			
			if Input.is_action_just_pressed("ui_down") :
				selected += 1
				if selected > 2 :
					selected = 0
			
				if selected < 0 :
					selected = 2
				AudioManager.play_audio(AudioManager.collect_audio)
				update_selection()
			
			if Input.is_action_just_pressed("ui_accept") :
				AudioManager.play_audio(AudioManager.jump_audio)
				match selected :
					0 :
						GameManager.fade_in("res://Scenes/Levels/save_room.tscn")
					1 :
						rebind_controls()
					2 :
						get_tree().quit()
	key_rebinding.set_frame_and_progress(to_rebind, 0)
	

func update_selection() -> void :
	for i in len(selection) :
		if i == selected :
			selection[i].set_frame_and_progress(1, 0)
		else :
			selection[i].set_frame_and_progress(0, 0)

func _unhandled_input(event: InputEvent):
	if Input.is_action_just_pressed("ui_cancel") :
		rebinding = false
		rebind_label.visible = false
		to_rebind = 0
		set_process_unhandled_input(false)
		GameManager.save_settings()
		return
	
	if event.pressed :
		match to_rebind :
			0 :
				InputMap.action_erase_events("Up")
				InputMap.action_add_event("Up", event)
			1 :
				InputMap.action_erase_events("Down")
				InputMap.action_add_event("Down", event)
			2 :
				InputMap.action_erase_events("Left")
				InputMap.action_add_event("Left", event)
			3 :
				InputMap.action_erase_events("Right")
				InputMap.action_add_event("Right", event)
			4 :
				InputMap.action_erase_events("Jump")
				InputMap.action_add_event("Jump", event)
			5 :
				InputMap.action_erase_events("Sprint")
				InputMap.action_add_event("Sprint", event)
			6 :
				InputMap.action_erase_events("Alt_Jump")
				InputMap.action_add_event("Alt_Jump", event)
			7 :
				InputMap.action_erase_events("Alt_Sprint")
				InputMap.action_add_event("Alt_Sprint", event)
				rebinding = false
				rebind_label.visible = false
				to_rebind = 0
				set_process_unhandled_input(false)
				GameManager.save_settings()
		to_rebind += 1

func rebind_controls() -> void :
	rebinding = true
	rebind_label.visible = true
	to_rebind = 0
	set_process_unhandled_input(true)

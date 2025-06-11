extends Node2D


func _ready() -> void:
	GameManager.load_speedrun_times()
	GameManager.fade_out(false)
	AudioManager.start_bgm("Results")
	
	var current_time_ui : int = 0
	
	for i in GameManager.times_list :
		if i == null :
			return
		current_time_ui += 1
		# To get hours (60 * 60) = 3600 * 10 (60 seconds * 60 minutes * Tenths in a second)
		var hours : int = i / 36000
		# Make i an integer for % modulus operation
		i = int(i)
		# This removes the hours from the total time, repeats for every unit
		i %= 36000
		# To get minutes (60 * 10) = 600 (seconds in a minute * tenths in a second)
		var minutes : int = i / 600
		i = int(i)
		i %= 600
		# To get seconds (10) because there are 10 tenths in a second
		var seconds : int = i / 10
		i = int(i)
		i %= 10
		var tseconds : int = i
		
		match current_time_ui :
			1 :
				$Time1/Hours.set_number(hours)
				$Time1/Minutes.set_number(minutes)
				$Time1/Seconds.set_number(seconds)
				$Time1/Tseconds.set_number(tseconds)
			2 :
				$Time2/Hours.set_number(hours)
				$Time2/Minutes.set_number(minutes)
				$Time2/Seconds.set_number(seconds)
				$Time2/Tseconds.set_number(tseconds)
			3 :
				$Time3/Hours.set_number(hours)
				$Time3/Minutes.set_number(minutes)
				$Time3/Seconds.set_number(seconds)
				$Time3/Tseconds.set_number(tseconds)
			4 :
				$Time4/Hours.set_number(hours)
				$Time4/Minutes.set_number(minutes)
				$Time4/Seconds.set_number(seconds)
				$Time4/Tseconds.set_number(tseconds)
			5 :
				$Time5/Hours.set_number(hours)
				$Time5/Minutes.set_number(minutes)
				$Time5/Seconds.set_number(seconds)
				$Time5/Tseconds.set_number(tseconds)

func _process(delta: float) -> void:
	$HubBackground.scroll_base_offset += Vector2(30 * delta, 0)
	$Borders.scroll_base_offset += Vector2(0, 100 * delta)

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_accept") :
		GameManager.fade_in("res://Scenes/Levels/save_room.tscn")

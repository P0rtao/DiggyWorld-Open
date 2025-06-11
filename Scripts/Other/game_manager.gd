extends Node
# Used to fix issues regarding old saves in newer versions
var game_version : String = "Test Version"


@onready var bone_queue: Timer = $BoneQueue
@onready var game_ui: CanvasLayer = $UI
@onready var animation_player: AnimationPlayer = $FadeInOut/Fade/AnimationPlayer

var can_pause : bool = true

# Hub World Position to return to, target scene to switch to (Fade in)
var last_position : Vector2
var target_scene : PackedScene

# Game Values
var bones : int = 0
var bonequeue : int
var lives : int = 3


# Settings Values
var master_volume: float = 0.801
var music_volume: float = 0.501
var sfx_volume: float = 0.501

#Saving
var settings_slot : String = "user://settings.json"
var loaded_slot : int
var save_slot_one : String = "user://save_slot1.json"
var save_slot_two : String = "user://save_slot2.json"
var save_slot_three : String = "user://save_slot3.json"


# Number of Levels Completed, List of all levels
var golden_bones : int = 0
var golden_bone_dict : Dictionary = {
	"Grass1" = false,
	"Grass2" = false,
	"Grass3" = false,
	"Grass4" = false,
	"Grass5" = false,
	"Grass6" = false,
	"GrassBoss" = false,
	"Sunridge1" = false,
	"Sunridge2" = false,
	"Sunridge3" = false,
	"Sunridge4" = false,
	"Sunridge5" = false,
	"Sunridge6" = false,
	"SunridgeBoss" = false,
	"Apocalypse1" = false,
	"Apocalypse2" = false,
	"Apocalypse3" = false,
	"Apocalypse4" = false,
	"Apocalypse5" = false,
	"Apocalypse6" = false,
	"ApocalypseBoss" = false,
	"Haunted1" = false,
	"Haunted2" = false,
	"Haunted3" = false,
	"Haunted4" = false,
	"Haunted5" = false,
	"Haunted6" = false,
	"HauntedBoss" = false,
	"TemporaryBone" = false,
	"Devoria" = false,
}

# Speedrun Mode
var speedrunactive : bool = false
@onready var speedrun_timer: Timer = $TimerUI/SpeedrunTimer

var speedrun_slot : String = "user://best_times.json"

var times_list : Array = []

var hours : int = 0
var minutes : int = 0
var seconds : int = 0
var tseconds : int = 0

func _ready() -> void:
	get_tree().paused = false
	load_settings()
	load_speedrun_times()
	# Loads first save file by default
	load_save_slot()
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(master_volume))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(music_volume))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(sfx_volume))

func _input(_event: InputEvent) -> void:
	# F11 Toggles Fullscreen and Windowed Modes
	if Input.is_action_just_pressed("ToggleFullscreen") :
		if DisplayServer.window_get_mode() == 0 :
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
		else :
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		save_settings()
	

func save_settings() -> void:
	var file : FileAccess = FileAccess.open(settings_slot, FileAccess.WRITE)
	
	var data_to_save : Dictionary = {
		"Master Volume": master_volume,
		"Music Volume": music_volume,
		"Sound Volume": sfx_volume,
		"Window Mode": DisplayServer.window_get_mode(),
		"Keybinds": {"Up" : InputMap.action_get_events("Up")[0].as_text_keycode(),
		"Down" : InputMap.action_get_events("Down")[0].as_text_keycode(),
		"Left" : InputMap.action_get_events("Left")[0].as_text_keycode(),
		"Right" : InputMap.action_get_events("Right")[0].as_text_keycode(),
		"Jump" : InputMap.action_get_events("Jump")[0].as_text_keycode(),
		"Sprint" : InputMap.action_get_events("Sprint")[0].as_text_keycode(),
		"Alt_Jump" : InputMap.action_get_events("Alt_Jump")[0].as_text_keycode(),
		"Alt_Sprint" : InputMap.action_get_events("Alt_Sprint")[0].as_text_keycode()}
	}
	
	file.store_line(JSON.stringify(data_to_save))
	
	file.close()
	file = null

func load_settings() -> void:
	var file : FileAccess = FileAccess.open(settings_slot, FileAccess.READ)
	
	if !FileAccess.file_exists(settings_slot) :
		return
	
	var json = JSON.new()
	
	json.parse(file.get_line())
	
	master_volume = json.data["Master Volume"]
	music_volume = json.data["Music Volume"]
	sfx_volume = json.data["Sound Volume"]
	change_setting("Resolution", json.data["Window Mode"])
	
	for i in json.data["Keybinds"] :
		if json.data["Keybinds"][i] == "(Unset)" :
			return
		
		var inputevent = InputEventKey.new()
		inputevent.keycode = OS.find_keycode_from_string(json.data["Keybinds"][i])
		
		InputMap.action_erase_events(i)
		InputMap.action_add_event(i, inputevent)
		
	

func save_save_slot(slot: int) -> void:
	var file : FileAccess
	
	match slot :
		1 :
			file = FileAccess.open(save_slot_one, FileAccess.WRITE)
		2 :
			file = FileAccess.open(save_slot_two, FileAccess.WRITE)
		3 :
			file = FileAccess.open(save_slot_three, FileAccess.WRITE)
	
	var data_to_save : Dictionary = {
		"Golden Bone Dict": golden_bone_dict,
		"Golden Bone Ammount": golden_bones,
		"Bones": bones,
		"Lives": lives,
		"Hub Position": last_position,
		"Game Version": game_version,
	}
	
	file.store_line(JSON.stringify(data_to_save))
	
	file.close()
	file = null

func delete_save_slot(slot: int) -> void:
	var dir : DirAccess = DirAccess.open("user://")
	
	match slot :
		1 :
			dir.remove("save_slot1.json")
		2 :
			dir.remove("save_slot2.json")
		3 :
			dir.remove("save_slot3.json")
		4 :
			dir.remove("best_times.json")
			for i in times_list.size() :
				times_list[i] = null
	

func load_save_slot(slot: int = 1) -> void:
	var file : FileAccess
	loaded_slot = slot
	
	match slot :
		0 :
			for i in golden_bone_dict.keys() :
				golden_bone_dict[i] = false
			golden_bones = 0
			bones = 0
			lives = 3
			last_position = Vector2()
			game_ui.update_gbones(golden_bones)
			game_ui.update_lives(lives)
			game_ui.update_bones(bones)
			return
		1 :
			file = FileAccess.open(save_slot_one, FileAccess.READ)
			
			# Load No Save Values if the save Doesnt exist
			if !FileAccess.file_exists(save_slot_one) :
				for i in golden_bone_dict.keys() :
					golden_bone_dict[i] = false
				golden_bones = 0
				bones = 0
				lives = 3
				last_position = Vector2()
				game_ui.update_gbones(golden_bones)
				game_ui.update_lives(lives)
				game_ui.update_bones(bones)
				return
		2 :
			file = FileAccess.open(save_slot_two, FileAccess.READ)
			
			# Load No Save Values if the save Doesnt exist
			if !FileAccess.file_exists(save_slot_two) :
				for i in golden_bone_dict.keys() :
					golden_bone_dict[i] = false
				golden_bones = 0
				bones = 0
				lives = 3
				last_position = Vector2()
				game_ui.update_gbones(golden_bones)
				game_ui.update_lives(lives)
				game_ui.update_bones(bones)
				return
		3 :
			file = FileAccess.open(save_slot_three, FileAccess.READ)
			
			# Load No Save Values if the save Doesnt exist
			if !FileAccess.file_exists(save_slot_three) :
				for i in golden_bone_dict.keys() :
					golden_bone_dict[i] = false
				golden_bones = 0
				bones = 0
				lives = 3
				last_position = Vector2()
				game_ui.update_gbones(golden_bones)
				game_ui.update_lives(lives)
				game_ui.update_bones(bones)
				return
	
	var json = JSON.new()
	
	json.parse(file.get_line())
	
	for i in json.data["Golden Bone Dict"].keys() :
		golden_bone_dict[i] = json.data["Golden Bone Dict"][i]
	
	golden_bones = json.data["Golden Bone Ammount"]
	bones = json.data["Bones"]
	lives = json.data["Lives"]
	
	if json.data.has("Game Version") :
		if json.data["Game Version"] == game_version :
			var positions = json.data["Hub Position"].split(",")
			var x = int(positions[0])
			var y = int(positions[1])
			var hubpos: Vector2 = Vector2(x, y)
			last_position = hubpos
		
	# Update UI
	game_ui.update_gbones(golden_bones)
	game_ui.update_lives(lives)
	game_ui.update_bones(bones)
	

func save_speedrun_time() :
	var current_time_ts : int = (((((hours * 60) + minutes) * 60 ) + seconds) * 10) + tseconds
	
	var times_stored : int = 0
	
	for i in times_list :
		if i != null :
			times_stored += 1
		
		if i == current_time_ts :
			return
	
	times_list.sort()
	times_list.resize(times_stored)
	times_list.append(current_time_ts)
	times_list.sort()
	times_list.resize(5)
	
	var file : FileAccess = FileAccess.open(speedrun_slot, FileAccess.WRITE)
	
	file.store_line(JSON.stringify(times_list))
	
	file.close()
	file = null

func load_speedrun_times() :
	if !FileAccess.file_exists(speedrun_slot) :
		return
	
	var file : FileAccess = FileAccess.open(speedrun_slot, FileAccess.READ)
	
	var json = JSON.new()
	
	json.parse(file.get_line())
	
	times_list = json.data
	
	file.close()
	file = null

func add_golden_bone(bone_name: String) -> void :
	# Only adds if the level isnt already completed
	if golden_bone_dict[bone_name] == false :
		golden_bone_dict[bone_name] = true
		golden_bones += 1
	game_ui.update_gbones(golden_bones)

func add_lives(num: int) -> void :
	# Lives cap is 99
	if lives < 99 :
		lives += num
	game_ui.update_lives(lives)

func remove_lives(num: int) -> void :
	if lives > 0 :
		lives -= num
	game_ui.update_lives(lives)

func set_lives(num: int) -> void :
	lives = num
	game_ui.update_lives(lives)

func add_bones(num: int) -> void :
	bonequeue += num
	if bone_queue.is_stopped() :
		bone_queue.start()


func _on_bone_queue_timeout() -> void:
	bonequeue -= 1
	bones += 1
	if bones >= 100 :
		bones = 0
		AudioManager.play_audio(AudioManager.life_audio)
		add_lives(1)
	game_ui.update_bones(bones)
	if bonequeue > 0 :
		bone_queue.start()

func fade_in(target : String) :
	target_scene = load(target)
	AudioManager.stop_bgm()
	animation_player.play("Fade_In")

func fade_timer() :
	if speedrunactive :
		$TimerUI.visible = true
	else :
		$TimerUI.visible = false

func fade_out(show_ui: bool) :
	get_tree().paused = false
	
	if show_ui :
		animation_player.play("Fade_Out")
		fade_timer()
	else :
		animation_player.play("Fade_Out_NOUI")
	
	if speedrunactive and speedrun_timer.is_stopped() :
		speedrun_timer.start()
	

func save_last_pos(pos: Vector2) :
	last_position = pos

func change_setting(setting: String, value: float) :
	match setting :
		"Master Volume" :
			master_volume += value
			
			if master_volume > 1.01 :
				master_volume -= value
			if master_volume < -0.00 :
				master_volume = 0.001
			
			AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(master_volume))
		"Music Volume" :
			music_volume += value
			
			if music_volume > 1.01 :
				music_volume -= value
			
			if music_volume < -0.00 :
				music_volume = 0.001
			
			AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(music_volume))
		"Sound Volume" :
			sfx_volume += value
			
			if sfx_volume > 1.01 :
				sfx_volume -= value
			if sfx_volume < -0.00 :
				sfx_volume = 0.001
			
			AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(sfx_volume))
		
		"Resolution" :
			if value == 4 :
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
			else :
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func start_speedrun() :
	speedrunactive = true
	hours = 0
	minutes = 0
	seconds = 0
	tseconds = 0

func end_speedrun(save_data : bool = false) :
	speedrunactive = false
	speedrun_timer.stop()
	
	if save_data :
		save_speedrun_time()
	
	hours = 0
	minutes = 0
	seconds = 0
	tseconds = 0
	
	for i in golden_bone_dict.keys() :
		golden_bone_dict[i] = false
	golden_bones = 0
	bones = 0
	lives = 3
	last_position = Vector2()
	game_ui.update_gbones(golden_bones)
	game_ui.update_lives(lives)
	game_ui.update_bones(bones)
	return

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	# Switches Scenes when the fade in effect ends
	if anim_name == "Fade_In" and target_scene :
		if target_scene != null :
			get_tree().change_scene_to_packed(target_scene)
	


func _on_speedrun_timer_timeout() -> void:
	tseconds += 1
	if tseconds > 9 :
		tseconds = 0
		seconds += 1
	if seconds > 59 :
		seconds = 0
		minutes += 1
	if minutes > 59 :
		minutes = 0
		hours += 1
	if hours > 99 :
		hours = 99
		speedrun_timer.stop()
	
	$TimerUI/NumberDisplay.set_number(hours)
	$TimerUI/NumberDisplay2.set_number(minutes)
	$TimerUI/NumberDisplay3.set_number(seconds)
	$TimerUI/NumberDisplay4.set_number(tseconds)

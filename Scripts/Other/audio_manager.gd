extends Node

@onready var jump_audio: AudioStreamPlayer = $JumpAudio
@onready var swim_audio: AudioStreamPlayer = $SwimAudio
@onready var spin_audio: AudioStreamPlayer = $SpinAudio
@onready var stomp_audio: AudioStreamPlayer = $StompAudio
@onready var collect_audio: AudioStreamPlayer = $CollectAudio
@onready var life_audio: AudioStreamPlayer = $LifeAudio
@onready var hurt_audio: AudioStreamPlayer = $HurtAudio
@onready var skid_audio: AudioStreamPlayer = $SkidAudio
@onready var death_audio: AudioStreamPlayer = $GameOver
@onready var big_stomp_audio: AudioStreamPlayer = $BigStompAudio
@onready var bounce_audio: AudioStreamPlayer = $BounceAudio
@onready var shatter_audio: AudioStreamPlayer = $ShatterAudio
@onready var gold_bone_audio: AudioStreamPlayer = $GoldenBone
@onready var bgm: AudioStreamPlayer = $BGM

func play_audio(audio) -> void :
	audio.play()

func golden_bone_audio(songname: String) :
	gold_bone_audio["parameters/switch_to_clip"] = songname
	gold_bone_audio.play()

func start_bgm(songname: String) :
	if !bgm["parameters/switch_to_clip"] == songname or !bgm.playing :
		bgm["parameters/switch_to_clip"] = songname
		bgm.play()

func stop_bgm() :
	bgm.stop()

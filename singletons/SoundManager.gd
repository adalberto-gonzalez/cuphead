extends Node

const PLAYER_SOUND_HURT = "hurt"
const PLAYER_SOUND_JUMP = "jump"
const PLAYER_SOUND_LAND = "land"
const PLAYER_SOUND_DASH = "dash"
const PLAYER_SOUND_SHOOT = "shoot"
const ANC_RUN_1 = "announcerR1"
const ANC_RUN_2 = "announcerR2"
const ANC_RUN_3 = "announcerR3"
const ANC_RUN_4 = "announcerR4"
const PARRY_SLAP = "parry_slap"
const PARRY_HIT = "parry_hit"

var SOUNDS = {
	PLAYER_SOUND_HURT : preload("res://assets/sound/player/player_hit_01.wav"),
	PLAYER_SOUND_JUMP : preload("res://assets/sound/player/player_jump_01.wav"),
	PLAYER_SOUND_LAND : preload("res://assets/sound/player/player_land_ground_01.wav"),
	PLAYER_SOUND_DASH : preload("res://assets/sound/player/player_dash_01.wav"),
	PLAYER_SOUND_SHOOT : preload("res://assets/sound/player/player_default_fire_loop_01.wav"),
	PARRY_HIT : preload("res://assets/sound/player/player_parry_power_up_hit_01.wav")
}

var ANNOUNCER = {
	ANC_RUN_1 : preload("res://assets/sound/announcer/announcer_0002_a.wav"),
	ANC_RUN_2 : preload("res://assets/sound/announcer/announcer_0002_b.wav"),
	ANC_RUN_3 : preload("res://assets/sound/announcer/announcer_0002_c.wav"),
	ANC_RUN_4 : preload("res://assets/sound/announcer/announcer_0002_d.wav")
}

func play_sound(audio_player: AudioStreamPlayer2D, clip_key: String):
	audio_player.stream = SOUNDS[clip_key]
	audio_player.play()
	
func play_sound_announcer(audio_player: AudioStreamPlayer, clip_key: String):
	audio_player.stream = ANNOUNCER[clip_key]
	audio_player.play()

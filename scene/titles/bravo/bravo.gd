extends CanvasLayer

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var timer: Timer = $Timer
@onready var audio: AudioStreamPlayer = $AudioStreamPlayer
@onready var clips

func _ready() -> void:
	SignalManager.bravo.connect(play_anim)

func play_anim() -> void:
	visible = true
	anim.play()
	SoundManager.play_sound_announcer(audio, SoundManager.ANC_BRAVO)

func _on_animated_sprite_2d_animation_finished() -> void:
	visible = false

func _on_audio_stream_player_finished() -> void:
	SignalManager.on_restart_game.emit()

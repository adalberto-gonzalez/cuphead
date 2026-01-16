extends CanvasLayer

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var timer: Timer = $Timer
@onready var audio: AudioStreamPlayer = $AudioStreamPlayer

func _ready() -> void:
	visible = false
	SignalManager.boss_killed.connect(play_anim)
	play_anim()

func _on_timer_timeout() -> void:
	audio.stop()
	#SignalManager.on_restart_game.emit()

func _on_animated_sprite_2d_animation_finished() -> void:
	visible = false

func play_anim():
	visible = true
	audio.play()
	anim.play("default")

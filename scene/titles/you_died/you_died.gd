extends CanvasLayer

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var timer: Timer = $Timer
@onready var audio: AudioStreamPlayer = $AudioStreamPlayer

func _ready() -> void:
	visible = false
	SignalManager.on_lives_changed.connect(on_death)

func _on_timer_timeout() -> void:
	audio.stop()
	#SignalManager.on_restart_game.emit()

func _on_animated_sprite_2d_animation_finished() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(anim, "modulate", Color(1,1,1, 0), 0.5)

func on_death(lives : int):
	if lives == 0:
		visible = true
		anim.play()
		audio.play()

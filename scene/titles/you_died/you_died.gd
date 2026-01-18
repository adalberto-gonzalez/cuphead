extends CanvasLayer

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var timer: Timer = $Timer
@onready var audio: AudioStreamPlayer = $AudioStreamPlayer
@export var level: String

func _ready() -> void:
	visible = false
	SignalManager.on_lives_changed.connect(on_death)

func _on_animated_sprite_2d_animation_finished() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(anim, "modulate", Color(1,1,1, 0), 0.5)
	audio.stop()
	SignalManager.pause.emit()

func on_death(lives : int):
	if lives == 0:
		timer.start()
		visible = true
		anim.play()
		audio.play()

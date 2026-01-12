extends MarginContainer

@onready var iris_reverse: AnimatedSprite2D = $Iris_reverse
@onready var bg: TextureRect = $Bg
@onready var cuphead: AnimatedSprite2D = $Cuphead
@onready var audio: AudioStreamPlayer = $AudioStreamPlayer

var song_second_part = preload("uid://6s7kxnf7l7p3")
var title_screen: bool = true

func _on_play_button_pressed():
	audio.stop()
	SceneTransition.go_to_scene("res://scene/island/island.tscn")

func _ready() -> void:
	SignalManager.any_key_pressed.connect(key_pressed)

func _on_exit():
	get_tree().quit()

func key_pressed():
	if title_screen:
		iris_reverse.visible = true
		iris_reverse.play()

func _on_iris_reverse_animation_finished() -> void:
	if !title_screen:
		iris_reverse.visible=false
	bg.visible = false
	cuphead.visible = false
	iris_reverse.play_backwards()
	title_screen = false

func _on_audio_stream_player_finished() -> void:
	audio.stream = song_second_part
	audio.play(0.0)

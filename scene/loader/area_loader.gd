extends Area2D

@export var target_scene_path: String = "res://scene/tutorial/tutorial.tscn"
@onready var audio: AudioStreamPlayer = $AudioStreamPlayer
const DISAPPEAR = preload("uid://cg6qsa23cpcyx")
const APPEAR = preload("uid://b10qfpf6brf1g")
var on_area: bool = false

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("jump") and on_area:
		SceneTransition.go_to_scene(target_scene_path)

func _on_area_entered(area: Area2D) -> void:
	on_area = true
	audio.stream = APPEAR
	audio.play(0.0)
	SignalManager.bubble_appear.emit()


func _on_area_exited(area: Area2D) -> void:
	on_area = false
	audio.stream = DISAPPEAR
	audio.play(0.0)
	SignalManager.bubble_disappear.emit()

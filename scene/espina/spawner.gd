extends Node2D

@onready var timer: Timer = $Timer
var on_area = false
var espinas = preload("res://scene/espina/espina.tscn")

func _ready() -> void:
	timer.start()

func _on_area_2d_area_entered(area: Area2D) -> void:
	on_area = true

func _on_area_2d_area_exited(area: Area2D) -> void:
	on_area = false

func _on_timer_timeout() -> void:
	if on_area:
		var espinas = espinas.instantiate()
		espinas.global_position = global_position
		get_tree().current_scene.add_child(espinas)
	timer.start()

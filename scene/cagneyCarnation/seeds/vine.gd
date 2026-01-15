extends Area2D

@onready var vine: AnimatedSprite2D = $vine
@onready var marker: Marker2D = $Marker2D
var finished = false

func _ready() -> void:
	vine.play()

func _on_vine_animation_finished() -> void:
	if finished:
		queue_free()
	else:
		ObjectMaker.create_flytrap(marker.global_position)
		vine.play_backwards("spawn")
		finished = true

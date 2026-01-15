extends "res://scene/enemies/Funhouse Frazzle/lips.gd"

@onready var acorn: AnimatedSprite2D = $acorn
func _ready() -> void:
	move = false
	acorn.play("default")

func _on_acorn_animation_finished() -> void:
	move = true
	acorn.play("idle")

extends Area2D

@export var impulse: float = -1900.0

func _on_body_entered(body: Node) -> void:
	if body is CharacterBody2D:
		body.velocity.y = impulse

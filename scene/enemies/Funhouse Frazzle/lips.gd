extends Area2D

var direction = Vector2.RIGHT
@export var bullet_speed : float = 200.0
var move = true

func _process(delta: float) -> void:
	if move:
		position += direction * bullet_speed * delta

func set_bullet_direction(target_position: Vector2):
	direction = (target_position - global_position).normalized()
	look_at(target_position)

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()

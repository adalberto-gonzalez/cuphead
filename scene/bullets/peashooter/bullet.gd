extends Area2D

var direction = Vector2.RIGHT
var bullet_speed : float = 3000.0
@onready var death: AnimatedSprite2D = $death
@onready var bullet: AnimatedSprite2D = $bullet

func _process(delta: float) -> void:
	position += direction * bullet_speed * delta

func set_bullet_direction(target_position: Vector2):
	direction = (target_position - global_position).normalized()
	look_at(target_position)

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()

func _on_death_animation_finished() -> void:
	queue_free()

func _on_area_entered(area: Area2D) -> void:
	bullet_speed = 0
	death.visible = true
	bullet.visible = false
	death.play()

func _on_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	bullet_speed = 0
	death.visible = true
	bullet.visible = false
	death.play()

func _on_body_entered(body: Node2D) -> void:
	bullet_speed = 0
	death.visible = true
	bullet.visible = false
	death.play()

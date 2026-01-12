extends StaticBody2D

@onready var smoke: AnimatedSprite2D = $Smoke
@onready var pyramid: Sprite2D = $Pyramid
@onready var target: AnimatedSprite2D = $Target
@onready var collision: CollisionShape2D = $CollisionShape2D
var lives = 5

func _on_hitbox_area_entered(area: Area2D) -> void:
	lives -= 1
	if(lives <= 0):
		smoke.visible = true
		pyramid.visible = false
		smoke.play()
		target.visible = false
		collision.disabled = true

func _on_smoke_animation_finished() -> void:
	queue_free()

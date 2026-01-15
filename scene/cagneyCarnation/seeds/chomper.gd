extends Area2D

@onready var collision: CollisionShape2D = $Collision
@onready var chomper: AnimatedSprite2D = $Chomper
var lives = 3

func _ready() -> void:
	scale = Vector2(0,0)
	var tween = get_tree().create_tween()
	tween.tween_property(self, "scale", Vector2(1,1), 0.1)


func _on_area_entered(area: Area2D) -> void:
	lives -= 1
	if lives <= 0:
		collision.set_deferred("disabled", true)
		chomper.play("death")

func _on_chomper_animation_finished() -> void:
	queue_free()

func _on_timer_timeout() -> void:
		collision.set_deferred("disabled", true)
		chomper.play("death")

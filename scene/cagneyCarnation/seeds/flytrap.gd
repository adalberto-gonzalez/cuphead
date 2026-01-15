extends Area2D

@onready var collision: CollisionShape2D = $collision
@onready var flytrap: AnimatedSprite2D = $Flytrap
@onready var player: Player = $"../Player"
var death = false
var speed := 160.0
var turn_speed := 5.0
var lives = 3

func _ready() -> void:
	flytrap.play("default")
	scale = Vector2(0,0)
	var tween = get_tree().create_tween()
	tween.tween_property(self, "scale", Vector2(1,1), 0.1)

func _process(delta: float) -> void:
	if player == null:
		return
	if !death:
		var target_angle := (player.global_position - global_position).angle()
		rotation = lerp_angle(rotation, target_angle, turn_speed * delta)

		var forward := Vector2.RIGHT.rotated(rotation)
		global_position += forward * speed * delta

func _on_area_entered(area: Area2D) -> void:
	lives -= 1
	if lives <= 0:
		collision.set_deferred("disabled", true)
		flytrap.play("death")
		death = true


func _on_flytrap_animation_finished() -> void:
	queue_free()


func _on_timer_timeout() -> void:
	death = true

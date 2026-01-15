extends Area2D

@onready var sprite: AnimatedSprite2D = $Card
var on_area: bool = false

func _ready() -> void:
	sprite.play("idle")

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("jump") and on_area:
		sprite.play("parried")
		SignalManager.on_parry.emit()
		SignalManager.on_gravity_inverted.emit()

func _on_area_entered(area: Area2D) -> void:
	on_area = true

func _on_area_exited(area: Area2D) -> void:
	on_area = false

func _on_card_animation_finished() -> void:
	sprite.play("idle")

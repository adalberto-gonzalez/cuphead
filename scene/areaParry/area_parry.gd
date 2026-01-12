extends Area2D

@export var sprite: AnimatedSprite2D
@export var parried: bool = false
var on_area: bool = false

func _ready() -> void:
	if parried:
		sprite.play("parried")
	else:
		sprite.play("default")

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("jump") and not parried and on_area:
		sprite.play("parried")
		SignalManager.on_parry.emit()
		parried = true

func _on_area_entered(area: Area2D) -> void:
	on_area = true

func reset():
	sprite.play("default")
	parried = false

func _on_area_exited(area: Area2D) -> void:
	on_area = false

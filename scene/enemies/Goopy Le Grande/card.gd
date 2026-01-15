extends CanvasLayer
@onready var card: Sprite2D = $BoxContainer/Card
@onready var bg: Sprite2D = $BoxContainer/BG

func _ready() -> void:
	bg.visible = true
	card.scale = Vector2(0,0)
	var tween = get_tree().create_tween()
	tween.set_ease(tween.EASE_IN)
	tween.set_loops(1)
	tween.tween_property(card, "scale", Vector2(1.7,1.7), 0.5)
	tween.tween_property(card, "scale", Vector2(1.5,1.5), 0.1)

extends Label

func _ready() -> void:
	modulate.a = 0.0

	var tween := get_tree().create_tween()
	tween.set_loops() # bucle infinito
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)

	tween.tween_property($".", "modulate:a", 1.0, 0.4)
	tween.tween_property($".", "modulate:a", 0.0, 0.4)

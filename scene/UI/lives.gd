extends CanvasLayer

@onready var ui: Sprite2D = $BoxContainer/UI

var current_lives: int = 3
var low_life_tween: Tween = null
var is_low_life := false

func _ready() -> void:
	SignalManager.on_lives_changed.connect(update)
	update(current_lives)

func update(lives: int) -> void:
	current_lives = lives

	if current_lives == 0:
		stop_low_life()
		ui.frame = 0
		return

	if current_lives == 1:
		start_low_life()
		return

	stop_low_life()
	ui.frame = current_lives + 2


func start_low_life() -> void:
	if is_low_life:
		return

	is_low_life = true

	low_life_tween = get_tree().create_tween()
	low_life_tween.set_loops()
	low_life_tween.tween_property(ui, "frame", 2, 0.2)
	low_life_tween.tween_property(ui, "frame", 3, 0.2)


func stop_low_life() -> void:
	is_low_life = false

	if low_life_tween:
		low_life_tween.kill()
		low_life_tween = null

extends CanvasLayer

@export var level: String

func _ready() -> void:
	SignalManager.pause.connect(pause)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		visible = !visible
		if visible:
			get_tree().paused = true
		else:
			get_tree().paused = false

func return_to_island():
	get_tree().paused = false
	SignalManager.on_restart_game.emit()

func retry():
	get_tree().paused = false
	GameManager.restart(level)

func pause():
	visible = true
	get_tree().paused = true

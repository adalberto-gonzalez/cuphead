extends Node

var lives = 1000

func _ready() -> void:
	SignalManager.on_hurt.connect(on_hurt_received)
	SignalManager.on_lives_changed.emit(lives)
	SignalManager.on_death.connect(kill)
	SignalManager.on_restart_game.connect(load_menu)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		SignalManager.any_key_pressed.emit()
		return

	if event is InputEventMouseButton and event.pressed:
		SignalManager.any_key_pressed.emit()
		return

	if event is InputEventJoypadButton and event.pressed:
		SignalManager.any_key_pressed.emit()
		return

	if event is InputEventJoypadMotion:
		if abs(event.axis_value) > 0.3: # deadzone
			SignalManager.any_key_pressed.emit()

func on_hurt_received():
	lives -= 1
	SignalManager.on_lives_changed.emit(lives)

func load_menu():
	SceneTransition.go_to_scene("res://scene/island/island.tscn")

func kill():
	lives = 0
	SignalManager.on_lives_changed.emit(lives)

func restart(level: String):
	lives = 3
	SceneTransition.go_to_scene(level)

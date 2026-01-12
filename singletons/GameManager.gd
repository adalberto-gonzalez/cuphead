extends Node

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

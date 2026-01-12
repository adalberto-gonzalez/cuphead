extends Camera2D

@export var player : CharacterBody2D
@onready var timer : Timer = $Timer
const SHAKE_AMOUNT : float = 5.0
const SHAKE_TIME : float = 0.7
var is_shaking : bool

func _ready() -> void:
	#SignalManager.on_hurt.connect(start_shaking)
	is_shaking = false

func _process(delta: float) -> void:
	position = player.position
	if is_shaking:
		offset = Vector2(
			randf_range(-SHAKE_AMOUNT, SHAKE_AMOUNT),
			randf_range(-SHAKE_AMOUNT, SHAKE_AMOUNT)
		)

func _on_timer_timeout() -> void:
	is_shaking = false
	offset = Vector2.ZERO

func start_shaking():
	is_shaking = true
	timer.start(SHAKE_TIME)

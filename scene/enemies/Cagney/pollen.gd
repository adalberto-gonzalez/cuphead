extends Area2D

# Configuración de movimiento
@export var horizontal_speed: float = -250.0  # Velocidad de izquierda a derecha (negativo = izquierda)
@export var amplitude: float = 50.0           # Amplitud de la onda senoidal
@export var frequency: float = 5.0             # Frecuencia de la onda senoidal

# Variables internas
var time_passed: float = 0.0
var initial_y: float = 0.0

func _ready() -> void:
	initial_y = global_position.y

func _process(delta: float) -> void:
	time_passed += delta
	
	# Movimiento horizontal (izquierda)
	global_position.x += horizontal_speed * delta
	
	# Movimiento vertical con onda senoidal
	var sine_offset = sin(time_passed * frequency) * amplitude
	global_position.y = initial_y + time_passed + sine_offset
	

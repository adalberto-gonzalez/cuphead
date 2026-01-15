# ShadowFollow.gd
extends AnimatedSprite2D

@export var platform_path: NodePath
@export var y_fixed: float = 0.0   # deja aquí la Y fija que quieras (en mundo)

var _platform: Node2D

func _ready() -> void:
	_platform = get_node_or_null(platform_path) as Node2D
	play() # mantiene animación

func _process(_delta: float) -> void:
	if _platform == null:
		return
	global_position.x = _platform.global_position.x
	global_position.y = y_fixed

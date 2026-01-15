extends Area2D

@export var speed: float = 320.0
@export var lifetime: float = 3.0
@onready var smoke: AnimatedSprite2D = $smoke
@onready var bullet: Sprite2D = $Bullet
var velocity: Vector2 = Vector2.ZERO
var collided:= false

func _ready() -> void:
	add_to_group("enemy_bullet")
	$Life.start(lifetime)

func _physics_process(delta: float) -> void:
	if !collided:
		global_position += velocity * delta

func _on_area_entered(body: Node) -> void:
	on_collision()

func _on_life_timeout() -> void:
	on_collision()
	
func _on_smoke_animation_finished() -> void:
	queue_free()

func on_collision():
	bullet.visible = false
	smoke.visible = true
	smoke.play()
	collided = true

extends CharacterBody2D

@export var speed: float = 160.0
@export var gravity: float = 1200.0
@export var jump_impulse: float = -450.0
@export var hp: int = 2

@onready var ray_up: RayCast2D = $RayCastUp
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var explosion_sprite: AnimatedSprite2D = $Explosion
@onready var collision: CollisionShape2D = $CollisionShape2D

enum STATE {MOVE, JUMP, EXPLODING}
var state: STATE
var initiated = false

var ignore_gravity := false

func _ready() -> void:
	sprite.play("idle")
	explosion_sprite.visible = false

func _physics_process(delta: float) -> void:
	if state == STATE.EXPLODING or !initiated:
		return
	if ray_up.is_colliding():
		var collider = ray_up.get_collider()
		if collider is CharacterBody2D:
			state = STATE.JUMP
	match state:
		STATE.MOVE:
			velocity.x = -1 * speed
			velocity.y = 0

		STATE.JUMP:
			sprite.play("rotating")
			state = STATE.JUMP
			ignore_gravity = true
			velocity.x = 0
			velocity.y = jump_impulse
	_apply_gravity(delta)
	
	if is_on_ceiling():
		_explode()
	move_and_slide()
	rotation = 0

func _apply_gravity(delta: float) -> void:
	if not ignore_gravity:
		velocity.y += gravity * delta

func _on_area_entered(body: Node) -> void:
	if state == STATE.EXPLODING:
		return
	_explode()

func _explode() -> void:
	if state == STATE.EXPLODING:
		return

	state = STATE.EXPLODING
	collision.disabled = true
	sprite.visible = false
	explosion_sprite.visible = true
	explosion_sprite.play("explode")
	explosion_sprite.connect(
		"animation_finished",
		Callable(self, "_on_explosion_finished"),
		Object.CONNECT_ONE_SHOT
	)

func _on_explosion_finished() -> void:
	queue_free()


func _on_detector_area_entered(area: Area2D) -> void:
	initiated = true

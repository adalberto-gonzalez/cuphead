extends CharacterBody2D

const MOVEMENT_SPEED : float = 200.0
const deadzone : float = 0.5

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var bubble: Node2D = $Bubble

func _ready() -> void:
	SignalManager.bubble_appear.connect(bubble_appear)
	SignalManager.bubble_disappear.connect(bubble_dissapear)

func _physics_process(_delta: float) -> void:
	var direction := Vector2.ZERO
	direction.x = int(Input.is_action_pressed("move_right")) - int(Input.is_action_pressed("move_left"))
	direction.y = int(Input.is_action_pressed("down")) - int(Input.is_action_pressed("up"))
	direction = direction.normalized()
	if direction != Vector2.ZERO:
		velocity = direction * MOVEMENT_SPEED
	else:
		velocity = velocity.move_toward(Vector2.ZERO, MOVEMENT_SPEED)

	move_and_slide()
	update_animation(direction)

func update_animation(direction: Vector2):
	if direction == Vector2.ZERO:
		sprite.play("idle")
		return

	if direction.x < -deadzone or direction.x > deadzone:
		sprite.flip_h = (direction.x < 0)

	if abs(direction.x) > deadzone and abs(direction.y) > deadzone:
		if direction.y > 0:
			sprite.play("walk_down_diagonal")
		elif direction.y < 0:
			sprite.play("walk_top_diagonal")
	else:
		if abs(direction.x) > deadzone:
			sprite.play("walk_side")
		elif direction.y > 0:
			sprite.play("walk_down")
		elif direction.y < 0:
			sprite.play("walk_up")

func bubble_appear():
	var tween = get_tree().create_tween()
	tween.set_ease(tween.EASE_IN)
	tween.set_loops(1)
	tween.tween_property(bubble, "scale", Vector2(1,1), 0.2)
	
func bubble_dissapear():
	var tween = get_tree().create_tween()
	tween.set_ease(tween.EASE_OUT)
	tween.set_loops(1)
	tween.tween_property(bubble, "scale", Vector2(0,0), 0.2)

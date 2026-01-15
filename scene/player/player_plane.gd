extends CharacterBody2D

const MOVEMENT_SPEED : float = 400.0
const deadzone : float = 0.5
var last_direction = Vector2.ZERO
var playing_move_anim: bool = false
var reversing_anim := false
var _screen_size

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var bubble: Node2D = $Bubble

func _ready() -> void:
	SignalManager.bubble_appear.connect(bubble_appear)
	SignalManager.bubble_disappear.connect(bubble_dissapear)
	_screen_size = get_viewport_rect().size

func _physics_process(_delta: float) -> void:
	var direction := Vector2.ZERO
	direction.x = int(Input.is_action_pressed("move_right")) - int(Input.is_action_pressed("move_left"))
	direction.y = int(Input.is_action_pressed("down")) - int(Input.is_action_pressed("up"))
	direction = direction.normalized()
	if direction != Vector2.ZERO:
		velocity = direction * MOVEMENT_SPEED
	else:
		velocity = velocity.move_toward(Vector2.ZERO, MOVEMENT_SPEED)
	position.x = clampf(position.x, 40, _screen_size.x - 40)
	position.y = clampf(position.y, 40, _screen_size.y - 40)
	move_and_slide()
	update_animation(direction)
	
func update_animation(direction: Vector2):
	# DEJÓ de moverse verticalmente
	if direction.y == 0 and last_direction.y != 0:
		if last_direction.y > 0:
			sprite.play_backwards("down")
		else:
			sprite.play_backwards("up")

		reversing_anim = true
		playing_move_anim = false
		last_direction = direction
		return

	# INICIO de movimiento vertical
	if direction.y > 0 and last_direction.y == 0:
		sprite.play("down")
		playing_move_anim = true

	elif direction.y < 0 and last_direction.y == 0:
		sprite.play("up")
		playing_move_anim = true

	last_direction = direction

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


func _on_animated_sprite_2d_animation_finished() -> void:
	# Fin de animación normal (entrada)
	if playing_move_anim:
		match sprite.animation:
			"down":
				sprite.play("idle_down")
			"up":
				sprite.play("idle_up")

		playing_move_anim = false
		return

	# Fin de animación en reversa (salida)
	if reversing_anim:
		sprite.play("idle")

		reversing_anim = false

extends CharacterBody2D

class_name Player

#region Enums y Constantes

enum PLAYER_STATES{IDLE, JUMP, RUN, FALL, HURT, DUCK, DASH, DEATH}

const SHOOT_OFFSETS := {
	"right": Vector2(63, 0),
	"left": Vector2(-63, 0),
	"up": Vector2(24, -76),
	"down": Vector2(24, 76),
	"up_right": Vector2(62, -48),
	"up_left": Vector2(-62, -48)
}

const MOVEMENT_SPEED : float = 400.0
const JUMP_SPEED : float = -1500.0
const GRAVITY : float = 4800.0
const MAX_FALL_SPEED : float = 2000.0
const HURT_JUMP_SPEED : float = -500.0
const DASH_SPEED : float = 750.0
const DEATH_SPEED = -4000

#endregion

#region Variables de Estado

var current_state : PLAYER_STATES = PLAYER_STATES.IDLE
var can_dash : bool = false
var can_shoot : bool = true
var shooting_input: bool = false
var hurt := false
var gravity_inverted := false

#endregion

#region Referencias de Nodos

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var audio_player: AudioStreamPlayer2D = $AudioPlayer
@onready var invincible_timer: Timer = $InvincibleTimer
@onready var dash_timer: Timer = $DashTimer
@onready var duck_hitbox: CollisionShape2D = $Duck/CollisionShape2D
@onready var hitbox: CollisionShape2D = $Hitbox/CollisionShape2D
@onready var shoot_timer : Timer = $ShootTimer
@onready var marker : Marker2D = $ShootMarker
@onready var shoot_fx: AnimatedSprite2D = $Spawn
@onready var bubble: Node2D = $Bubble
@onready var shoot_audio: AudioStreamPlayer2D = $ShootAudio
@onready var action_player: AudioStreamPlayer2D = $Action
@onready var collision: CollisionShape2D = $CollisionShape2D

#endregion

#region Inicialización

func _ready() -> void:
	sprite.play("idle")
	# Conexión de señales del sistema
	SignalManager.bubble_appear.connect(bubble_appear)
	SignalManager.bubble_disappear.connect(bubble_dissapear)
	SignalManager.on_parry.connect(parry)
	SignalManager.on_lives_changed.connect(on_death)
	SignalManager.on_gravity_inverted.connect(invert_gravity)

#endregion

#region Loops Principales

func _process(delta: float) -> void:
	# Durante dash o muerte no se puede disparar
	if current_state == PLAYER_STATES.DASH or current_state == PLAYER_STATES.DEATH:
		stop_shooting()
		return

	shooting_input = Input.is_action_pressed("shoot")

	if shooting_input:
		handle_shooting()
	else:
		stop_shooting_audio()

func _physics_process(delta: float) -> void:
	if current_state != PLAYER_STATES.DASH and current_state != PLAYER_STATES.DEATH:
		# Aplicar gravedad cuando no está en el suelo
		if not is_on_ground():
			if !gravity_inverted:
				velocity.y += GRAVITY * delta
			else:
				velocity.y -= GRAVITY * delta
		else:
			can_dash = true
			if velocity.y > 0:
				velocity.y = 0
				can_dash = true
			# Manejo de hitboxes según el estado
			if current_state == PLAYER_STATES.DUCK and !hurt and current_state != PLAYER_STATES.DEATH:
				hitbox.disabled = true
				duck_hitbox.disabled = false
			elif !hurt and current_state != PLAYER_STATES.DEATH:
				hitbox.disabled = false
				duck_hitbox.disabled = true
		
		# Limitar velocidad de caída
		if gravity_inverted:
			velocity.y = clampf(velocity.y, -MAX_FALL_SPEED, -JUMP_SPEED)
		else:
			velocity.y = clampf(velocity.y, JUMP_SPEED, MAX_FALL_SPEED)

		get_input(delta)
		calculate_state()
	elif current_state == PLAYER_STATES.DEATH:
		velocity.y = DEATH_SPEED * delta
		
	update_animation()
	move_and_slide()

#endregion

#region Input y Movimiento

func get_input(_delta: float):
	# No procesar input durante dash o muerte
	if current_state == PLAYER_STATES.DASH or current_state == PLAYER_STATES.DEATH:
		velocity.x = 0
		return

	# No moverse mientras está agachado
	if current_state == PLAYER_STATES.DUCK:
		velocity.x = 0
		return
		
	velocity.x = 0 

	# Movimiento horizontal
	if Input.is_action_pressed("move_left"):
		if not Input.is_action_pressed("block"):
			velocity.x = -MOVEMENT_SPEED
		sprite.flip_h = true
	elif Input.is_action_pressed("move_right"):
		if not Input.is_action_pressed("block"):
			velocity.x = MOVEMENT_SPEED
		sprite.flip_h = false 
	
	# Salto
	if Input.is_action_just_pressed("jump") and is_on_ground():
		velocity.y = get_jump_speed()
		
	# Dash
	if Input.is_action_just_pressed("dash") and can_dash:
		start_dash()

func start_dash():
	stop_shooting()
	set_state(PLAYER_STATES.DASH)
	can_dash = false

	var dash_direction = -1 if sprite.flip_h else 1
	velocity.x = dash_direction * DASH_SPEED
	velocity.y = 0

	dash_timer.start()

#endregion

#region Estados

func calculate_state():
	var duck_input := Input.is_action_pressed("up") if gravity_inverted else Input.is_action_pressed("down")

	if current_state == PLAYER_STATES.DASH or current_state == PLAYER_STATES.DEATH:
		return

	# Estados en el suelo
	if is_on_ground():
		if duck_input and not Input.is_action_pressed("move_left") and not Input.is_action_pressed("move_right"):
			set_state(PLAYER_STATES.DUCK)
		elif velocity.x == 0:
			set_state(PLAYER_STATES.IDLE)
		else:
			set_state(PLAYER_STATES.RUN)
		return

	# Estados en el aire (considerando gravedad invertida)
	if gravity_inverted:
		if velocity.y > 0:
			set_state(PLAYER_STATES.JUMP)
		else:
			set_state(PLAYER_STATES.FALL)
	else:
		if velocity.y < 0:
			set_state(PLAYER_STATES.JUMP)
		else:
			set_state(PLAYER_STATES.FALL)

func set_state(new_state: PLAYER_STATES):
	if current_state == new_state:
		return

	# Reproducir sonido de aterrizaje
	if current_state == PLAYER_STATES.FALL and new_state in [PLAYER_STATES.IDLE, PLAYER_STATES.RUN]:
		SoundManager.play_sound(audio_player, SoundManager.PLAYER_SOUND_LAND)

	current_state = new_state

	# Reproducir sonidos según el estado
	match new_state:
		PLAYER_STATES.JUMP:
			SoundManager.play_sound(audio_player, SoundManager.PLAYER_SOUND_JUMP)
		PLAYER_STATES.HURT:
			SoundManager.play_sound(audio_player, SoundManager.PLAYER_SOUND_HURT)
		PLAYER_STATES.DASH:
			SoundManager.play_sound(audio_player, SoundManager.PLAYER_SOUND_DASH)

#endregion

#region Animaciones

func update_animation():
	if current_state == PLAYER_STATES.DEATH:
		play_anim("death")
		return
	if current_state == PLAYER_STATES.DASH:
		play_anim("dash")
		return

	if not is_on_ground():
		play_anim("jump")
		return

	if Input.is_action_pressed("shoot"):
		shooting_anim()
		return

	match current_state:
		PLAYER_STATES.IDLE:
			play_anim("idle")
		PLAYER_STATES.RUN:
			play_anim("run")
		PLAYER_STATES.HURT:
			play_anim("idle")
		PLAYER_STATES.DUCK:
			play_anim("duck")

func play_anim(name: String):
	if sprite.animation != name:
		sprite.play(name)

func shooting_anim():
	var x := Input.get_axis("move_left", "move_right")
	var y := Input.get_axis("up", "down")

	var moving_x := velocity.x != 0
	var side := x != 0
	var up := y < 0 if !gravity_inverted else y > 0
	var down := y > 0 if !gravity_inverted else y < 0

	if down and is_on_ground() and not moving_x:
		play_anim("duck_shoot")
		return

	if moving_x and up:
		play_anim("run_shoot_up")
	elif moving_x:
		play_anim("run_shoot_side")
	elif up and side:
		play_anim("shoot_diagonal")
	elif up:
		sprite.flip_h = false
		play_anim("shoot_up")
	else:
		play_anim("shoot_straight")

#endregion

#region Disparo

func handle_shooting():
	if not shoot_audio.playing:
		shoot_audio.play()

	if can_shoot:
		fire()

func fire():
	can_shoot = false
	shoot_timer.start()

	# Posicionar marcador y efectos según dirección
	marker.position = SHOOT_OFFSETS[get_shoot_direction()]
	shoot_fx.position = SHOOT_OFFSETS[get_shoot_direction()]
	shoot_fx.visible = true
	shoot_fx.play("fx")

	ObjectMaker.create_player_bullet(calculate_direction(), marker.global_position)

func stop_shooting():
	stop_shooting_audio()
	shoot_fx.visible = false

func stop_shooting_audio():
	if shoot_audio.playing:
		shoot_audio.stop()

func get_shoot_direction() -> String:
	var x := Input.get_axis("move_left", "move_right")
	var y := Input.get_axis("up", "down")

	# Direcciones diagonales
	if !gravity_inverted:
		if x > 0 and y < 0: return "up_right"
		if x < 0 and y < 0: return "up_left"
	else:
		if x > 0 and y > 0: return "up_right"
		if x < 0 and y > 0: return "up_left"

	# Dirección arriba
	if !gravity_inverted and y < 0:
		return "up"
	if gravity_inverted and y > 0:
		return "up"

	# Direcciones horizontales
	if x < 0: return "left"
	if x > 0: return "right"

	return "left" if sprite.flip_h else "right"

func calculate_direction() -> Vector2:
	var x_dir := 0
	var y_dir := 0

	# Horizontal
	if Input.is_action_pressed("move_left"):
		x_dir = -1
	elif Input.is_action_pressed("move_right"):
		x_dir = 1

	# Vertical
	if Input.is_action_pressed("up"):
		y_dir = -1
	if Input.is_action_pressed("down") and is_on_ground():
		x_dir = -1 if sprite.flip_h else 1
		y_dir = 0

	# Dirección por defecto si no hay input
	if x_dir == 0 and y_dir == 0:
		x_dir = -1 if sprite.flip_h else 1

	return Vector2(x_dir, y_dir)

#endregion

#region Daño y Muerte

func apply_hit():
	hurt = true
	if current_state != PLAYER_STATES.DEATH:
		invincible_timer.start()
		hitbox.set_deferred("disabled", true)
		duck_hitbox.set_deferred("disabled", true)
	SignalManager.on_hurt.emit()
	SoundManager.play_sound(audio_player, SoundManager.PLAYER_SOUND_HURT)
	
	var tween = get_tree().create_tween()
	tween.set_loops(6)
	tween.tween_property(sprite, "self_modulate", Color(1,1,1, 0.3), 0.166)
	tween.tween_property(sprite, "self_modulate", Color(1,1,1, 1), 0.166)

func on_death(lives : int):
	if lives <= 0:
		set_state(PLAYER_STATES.DEATH)
		sprite.scale = Vector2(0.7,0.7)
		velocity.x = 0
		sprite.flip_v = false
		hitbox.set_deferred("disabled", true)
		duck_hitbox.set_deferred("disabled", true)
		collision.set_deferred("disabled", true)

#endregion

#region Mecánicas Especiales

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

func parry():
	# Impulso hacia arriba al hacer parry
	if gravity_inverted:
		velocity.y = abs(JUMP_SPEED)
	else:
		velocity.y = JUMP_SPEED

	SoundManager.play_sound(action_player, SoundManager.PARRY_HIT)

func invert_gravity():
	gravity_inverted = !gravity_inverted
	sprite.flip_v = gravity_inverted
	velocity.y *= -2

#endregion

#region Utilidades

func is_on_ground() -> bool:
	if gravity_inverted:
		return is_on_ceiling()
	else:
		return is_on_floor()

func get_jump_speed() -> float:
	return -JUMP_SPEED if gravity_inverted else JUMP_SPEED

#endregion

#region Señales

func _on_hitbox_area_entered(_area: Area2D) -> void:
	apply_hit()

func _on_dash_timer_timeout() -> void:
	if current_state == PLAYER_STATES.DASH:
		velocity.x = 0
		if is_on_ground():
			set_state(PLAYER_STATES.IDLE)
		else:
			set_state(PLAYER_STATES.FALL)

func _on_shoot_timer_timeout() -> void:
	can_shoot = true
	if Input.is_action_pressed("shoot"):
			return

func _on_spawn_animation_finished() -> void:
	shoot_fx.visible = false

func _on_invincible_timer_timeout() -> void:
	hitbox.disabled = false
	hurt = false

#endregion

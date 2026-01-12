extends CharacterBody2D

class_name Player

enum PLAYER_STATES{IDLE, JUMP, RUN, FALL, HURT, DUCK, DASH}

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
const HURT_JUMP_SPEED : float = -100.0
const DASH_SPEED : float = 750.0

var current_state : PLAYER_STATES = PLAYER_STATES.IDLE
var can_dash : bool = false
var can_shoot : bool = true
var shooting_input: bool = false

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

func _ready() -> void:
	sprite.play("idle")
	SignalManager.bubble_appear.connect(bubble_appear)
	SignalManager.bubble_disappear.connect(bubble_dissapear)
	SignalManager.on_parry.connect(parry)

func _process(delta: float) -> void:
	if current_state == PLAYER_STATES.DASH:
		stop_shooting()
		return

	shooting_input = Input.is_action_pressed("shoot")

	if shooting_input:
		handle_shooting()
	else:
		stop_shooting_audio()



func _physics_process(delta: float) -> void:
	if current_state == PLAYER_STATES.HURT:
		move_and_slide()
		return

	if current_state != PLAYER_STATES.DASH:
		if not is_on_floor():
			velocity.y += GRAVITY * delta
		else:
			can_dash = true
			if velocity.y > 0:
				velocity.y = 0
				can_dash = true
			if current_state == PLAYER_STATES.DUCK:
				hitbox.disabled = true
				duck_hitbox.disabled = false
			else:
				hitbox.disabled = false
				duck_hitbox.disabled = true
		
		velocity.y = clampf(velocity.y, JUMP_SPEED, MAX_FALL_SPEED)
		get_input(delta)
		calculate_state()
	update_animation()
	move_and_slide()

func get_input(_delta: float):
	if current_state == PLAYER_STATES.DUCK or current_state == PLAYER_STATES.DASH:
		velocity.x = 0
		if current_state == PLAYER_STATES.DASH: return
	else:
		velocity.x = 0 
		if Input.is_action_pressed("move_left"):
			if not Input.is_action_pressed("block"):
				velocity.x = -MOVEMENT_SPEED
			sprite.flip_h = true
		elif Input.is_action_pressed("move_right"):
			if not Input.is_action_pressed("block"):
				velocity.x = MOVEMENT_SPEED
			sprite.flip_h = false 
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_SPEED
		
	if Input.is_action_just_pressed("dash") and can_dash:
		start_dash()

func start_dash():
	stop_shooting()   # ⬅️ cancelar disparo
	set_state(PLAYER_STATES.DASH)
	can_dash = false

	var dash_direction = -1 if sprite.flip_h else 1
	velocity.x = dash_direction * DASH_SPEED
	velocity.y = 0

	dash_timer.start()

func calculate_state():
	if current_state == PLAYER_STATES.DASH:
		return

	if is_on_floor():
		if Input.is_action_pressed("down") and not Input.is_action_pressed("move_left") and not Input.is_action_pressed("move_right"):
			set_state(PLAYER_STATES.DUCK)
		elif velocity.x == 0:
			set_state(PLAYER_STATES.IDLE)
		else:
			set_state(PLAYER_STATES.RUN)
	else:
		if velocity.y < 0:
			set_state(PLAYER_STATES.JUMP)
		else:
			set_state(PLAYER_STATES.FALL)

func set_state(new_state: PLAYER_STATES):
	if current_state == new_state:
		return

	if current_state == PLAYER_STATES.FALL and new_state in [PLAYER_STATES.IDLE, PLAYER_STATES.RUN]:
		SoundManager.play_sound(audio_player, SoundManager.PLAYER_SOUND_LAND)

	current_state = new_state

	match new_state:
		PLAYER_STATES.JUMP:
			SoundManager.play_sound(audio_player, SoundManager.PLAYER_SOUND_JUMP)
		PLAYER_STATES.HURT:
			SoundManager.play_sound(audio_player, SoundManager.PLAYER_SOUND_HURT)
		PLAYER_STATES.DASH:
			SoundManager.play_sound(audio_player, SoundManager.PLAYER_SOUND_DASH)

func update_animation():
	if current_state == PLAYER_STATES.DASH:
		play_anim("dash")
		return

	if not is_on_floor():
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

func apply_hit():
	velocity.x = 0
	velocity.y = HURT_JUMP_SPEED
	set_state(PLAYER_STATES.HURT)
	invincible_timer.start()
	
	var tween = get_tree().create_tween()
	tween.set_loops(3)
	tween.tween_property(sprite, "self_modulate", Color(1,0,0, 0.5), 0.166)
	tween.tween_property(sprite, "self_modulate", Color(1,1,1, 1), 0.166)

func handle_shooting():
	if not shoot_audio.playing:
		shoot_audio.play()

	if can_shoot:
		fire()

func stop_shooting():
	stop_shooting_audio()
	shoot_fx.visible = false

func fire():
	can_shoot = false
	shoot_timer.start()

	marker.position = SHOOT_OFFSETS[get_shoot_direction()]
	shoot_fx.position = SHOOT_OFFSETS[get_shoot_direction()]
	shoot_fx.visible = true
	shoot_fx.play("fx")

	ObjectMaker.create_player_bullet(calculate_direction(), marker.global_position)

func stop_shooting_audio():
	if shoot_audio.playing:
		shoot_audio.stop()

func shooting_anim():
	var x := Input.get_axis("move_left", "move_right")
	var y := Input.get_axis("up", "down")

	var moving_x := velocity.x != 0
	var side := x != 0
	var up := y < 0
	var down := y > 0

	if moving_x and up:
		play_anim("run_shoot_up")
	elif moving_x:
		play_anim("run_shoot_side")
	elif up and side:
		play_anim("shoot_diagonal")
	elif up:
		sprite.flip_h = false
		play_anim("shoot_up")
	elif down and not side:
		sprite.flip_h = false
		play_anim("shoot_down")
	else:
		play_anim("shoot_straight")

func get_shoot_direction() -> String:
	var x := Input.get_axis("move_left", "move_right")
	var y := Input.get_axis("up", "down")

	if x > 0 and y < 0: return "up_right"
	if x < 0 and y < 0: return "up_left"
	if x > 0 and y > 0: return "right"
	if x < 0 and y > 0: return "left"
	if y < 0: return "up"
	if y > 0: return "down"
	return "left" if sprite.flip_h else "right"

func _on_hitbox_area_entered(_area: Area2D) -> void:
	apply_hit()

func _on_dash_timer_timeout() -> void:
	if current_state == PLAYER_STATES.DASH:
		velocity.x = 0
		if is_on_floor():
			set_state(PLAYER_STATES.IDLE)
		else:
			set_state(PLAYER_STATES.FALL)

func _on_shoot_timer_timeout() -> void:
	can_shoot = true
	if Input.is_action_pressed("shoot"):
			return

func _on_spawn_animation_finished() -> void:
	shoot_fx.visible = false

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
	elif Input.is_action_pressed("down"):
		if x_dir == 0:
			y_dir = 1
		else:
			y_dir = 0

	if x_dir == 0 and y_dir == 0:
		x_dir = -1 if sprite.flip_h else 1

	return Vector2(x_dir, y_dir)

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
	velocity.y = JUMP_SPEED
	SoundManager.play_sound(action_player, SoundManager.PARRY_HIT)

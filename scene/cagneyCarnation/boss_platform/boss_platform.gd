extends AnimatableBody2D

@export var amplitude: float = 12.0
@export var speed: float = 0.8
@export var phase_offset: float = 0.0        # 0 = normal, PI = contrario

@export var sink_amount: float = 6.0         # se hunde esta cantidad (px)
@export var sink_speed: float = 140.0        # velocidad del hundimiento (px/seg)

@export var top_sensor_path: NodePath = ^"TopSensor"
@export var shadow_path: NodePath = ^"Shadow"

var _base_pos: Vector2
var _t: float = 0.0

var _paused: bool = false
var _press_target_y: float = 0.0
var _captured_press: bool = false

var _shadow_fixed_pos: Vector2
var _shadow: AnimatedSprite2D
var _top_sensor: Area2D

# Anti micro-salto
var _last_free_y: float = 0.0
var _last_free_t: float = 0.0

# NUEVO: guardar dirección (subiendo/bajando) antes de pausar
# cos(t+phase_offset) > 0 => bajando (y aumenta)
# cos(t+phase_offset) < 0 => subiendo (y disminuye)
var _last_vel_sign: int = 1

func _ready() -> void:
	_base_pos = global_position

	_shadow = get_node_or_null(shadow_path) as AnimatedSprite2D
	if _shadow == null:
		push_error("No encuentro Shadow. Revisa shadow_path: " + str(shadow_path))
		return

	_shadow_fixed_pos = _shadow.global_position
	_shadow.set_as_top_level(true)
	_shadow.global_position = _shadow_fixed_pos

	_top_sensor = get_node_or_null(top_sensor_path) as Area2D
	if _top_sensor == null:
		push_error("No encuentro TopSensor. Revisa top_sensor_path: " + str(top_sensor_path))
		return
	_top_sensor.monitoring = true

	# Animaciones
	for n in find_children("*", "AnimatedSprite2D", true, false):
		var a: AnimatedSprite2D = n as AnimatedSprite2D
		if a.sprite_frames:
			a.play()

	_last_free_y = global_position.y
	_last_free_t = _t
	_last_vel_sign = _vel_sign_from_t(_t)

func _physics_process(delta: float) -> void:
	# Sombra fija (sigue X; borra esta línea si la quieres totalmente fija)
	_shadow_fixed_pos.x = global_position.x
	_shadow.global_position = _shadow_fixed_pos

	var standing := _someone_standing_on_me()

	# Libre -> pisada
	if standing and not _paused:
		_paused = true
		_captured_press = false

		# volver al estado libre anterior (evita micro “brinco”)
		global_position.y = _last_free_y
		_t = _last_free_t

	# Pisada -> libre
	elif (not standing) and _paused:
		_paused = false
		_captured_press = false
		_recompute_t_from_current_y_keep_direction()  # <- conserva dirección

	# Modo pisada (hundimiento)
	if _paused:
		if not _captured_press:
			# hunde hacia abajo (Y positivo)
			_press_target_y = global_position.y + sink_amount
			_captured_press = true

		var cur_y := global_position.y
		var new_y := move_toward(cur_y, _press_target_y, sink_speed * delta)
		global_position.y = max(new_y, cur_y)  # nunca subir mientras está pisada
		return

	# Guardar estado libre ANTES de mover (y guardar dirección)
	_last_free_y = global_position.y
	_last_free_t = _t
	_last_vel_sign = _vel_sign_from_t(_t)

	# Movimiento normal (CON phase_offset)
	_t += delta * speed
	global_position = _base_pos + Vector2(0.0, sin(_t + phase_offset) * amplitude)

func _vel_sign_from_t(tval: float) -> int:
	var c: float = cos(tval + phase_offset)
	# evita 0 exacto
	if abs(c) < 0.00001:
		return 1
	return 1 if c > 0.0 else -1

func _recompute_t_from_current_y_keep_direction() -> void:
	if amplitude == 0.0:
		return

	var ratio: float = clamp((global_position.y - _base_pos.y) / amplitude, -1.0, 1.0)

	# Resolver sin(t + phase_offset) = ratio
	var base_a: float = asin(ratio)
	var cand1: float = base_a - phase_offset
	var cand2: float = (PI - base_a) - phase_offset

	# Elegir candidato que conserve la dirección (signo de cos)
	var s1: int = _vel_sign_from_t(cand1)
	var s2: int = _vel_sign_from_t(cand2)

	var use1: bool
	if s1 == _last_vel_sign and s2 != _last_vel_sign:
		use1 = true
	elif s2 == _last_vel_sign and s1 != _last_vel_sign:
		use1 = false
	else:
		# si ambos coinciden (o ninguno), elige el más cercano para continuidad
		use1 = abs(_angle_diff(_t, cand1)) <= abs(_angle_diff(_t, cand2))

	_t = cand1 if use1 else cand2

func _someone_standing_on_me() -> bool:
	for b in _top_sensor.get_overlapping_bodies():
		if b is CharacterBody2D and _is_standing_on_me(b as CharacterBody2D):
			return true
	return false

func _is_standing_on_me(body: CharacterBody2D) -> bool:
	if not body.is_on_floor():
		return false

	var count := body.get_slide_collision_count()
	for i in range(count):
		var col := body.get_slide_collision(i)
		if col == null:
			continue
		if col.get_normal().y < -0.7 and col.get_collider() == self:
			return true
	return false

func _angle_diff(from_angle: float, to_angle: float) -> float:
	return fmod(to_angle - from_angle + PI, TAU) - PI

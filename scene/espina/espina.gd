extends CharacterBody2D

# --- CONFIGURACIÓN ---
@export var velocidad_patrulla = 100.0
@export var velocidad_persecucion = 180.0
@export var rango_patrulla = 300.0 

# Referencias
@onready var anim = $AnimatedSprite2D

# Estados
enum ESTADO { PATRULLAR, PERSEGUIR }
var estado_actual = ESTADO.PATRULLAR
var punto_inicial_y : float 
var objetivo : Node2D = null 

# NUEVA VARIABLE: Para saber si ya le dimos
var esta_muerto : bool = false

func _ready() -> void:
	punto_inicial_y = global_position.y
	anim.play("idle")

func _physics_process(delta: float) -> void:
	if esta_muerto:
		return 

	match estado_actual:
		ESTADO.PATRULLAR:
			comportamiento_patrullar(delta)
		ESTADO.PERSEGUIR:
			comportamiento_perseguir(delta)

	move_and_slide()
	
	if velocity.x != 0:
		anim.flip_h = velocity.x > 0

# --- FUNCIONES DE MOVIMIENTO ---

func comportamiento_patrullar(delta):
	if anim.animation != "idle": anim.play("idle")
	var tiempo = Time.get_ticks_msec() / 1000.0 
	var nueva_y = punto_inicial_y + sin(tiempo) * rango_patrulla
	velocity.y = (nueva_y - global_position.y) * 5
	velocity.x = 0 

func comportamiento_perseguir(delta):
	if anim.animation != "seguir": anim.play("seguir")
	if objetivo:
		var direccion = (objetivo.global_position - global_position).normalized()
		velocity = direccion * velocidad_persecucion

# --- DETECCIÓN DE JUGADOR ---

func _on_area_vision_body_entered(body: Node2D) -> void:
	if body is Player and not esta_muerto:
		objetivo = body
		estado_actual = ESTADO.PERSEGUIR

func _on_area_vision_body_exited(body: Node2D) -> void:
	if body is Player and not esta_muerto:
		objetivo = null
		estado_actual = ESTADO.PATRULLAR
		punto_inicial_y = global_position.y

func recibir_dano():
	if esta_muerto: return
	esta_muerto = true
	velocity = Vector2.ZERO 
	$CollisionShape2D.set_deferred("disabled", true)
	anim.play("death")
	await anim.animation_finished
	queue_free()

func _on_hitbox_area_entered(area: Area2D) -> void:
	recibir_dano()

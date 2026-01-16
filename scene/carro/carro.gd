extends CharacterBody2D

@export var velocidad = 180 
@onready var anim = $AnimatedSprite2D
@onready var collision: CollisionShape2D = $Area2DCarro/CollisionShape2D

# 1. Definimos la vida inicial
var vida : int = 5

func _ready() -> void:
	anim.play("caminar")

func _physics_process(delta):
	velocity.x = -velocidad
	move_and_slide()

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

func recibir_dano():
	if vida <= 0: return

	# Restamos vida
	vida -= 1
	print("Vida del enemigo: ", vida)
	
	# Efecto flash rojo
	var tween = get_tree().create_tween()
	anim.modulate = Color(1, 0, 0)
	tween.tween_property(anim, "modulate", Color(1, 1, 1), 0.1)

	# Lógica de Muerte
	if vida <= 0:
		velocidad = 0 # Frenar
		anim.play("death") # Asegúrate que la animación se llame EXACTAMENTE "death" en SpriteFrames
		collision.set_deferred("disabled", true)
		# Desactivar colisión física para que el jugador pueda pasar por encima de la explosión
		$CollisionShape2D.set_deferred("disabled", true)
		
		# Esperar
		await anim.animation_finished
		
		# Eliminar
		queue_free()

func _on_area_2d_carro_area_entered(area: Area2D) -> void:
	recibir_dano()

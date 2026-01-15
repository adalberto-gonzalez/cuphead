extends Area2D

@export var fire_interval: float = 2.2
@export var bullet_speed: float = 360.0
@export var hp: int = 6

var angle_offset: float = 0.0
var bullet_scene := preload("res://scene/funfair_fever/blaster_bullet.tscn")

@onready var star: AnimatedSprite2D = $Star
@onready var barrel_h: AnimatedSprite2D = $Barrel
@onready var barrel_v: AnimatedSprite2D = $BarrelV
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var fire_timer: Timer = $FireTimer

func _ready() -> void:
	star.play("idle")
	barrel_h.play("idle")
	barrel_v.play("idle")
	fire_timer.wait_time = fire_interval
	fire_timer.start()
	connect("area_entered", Callable(self, "_on_area_entered"))

func _on_fire_timer_timeout() -> void:
	star.play("shoot")
	barrel_h.play("shoot")
	barrel_v.play("shoot")
	_fire_volley()
	await star.animation_finished
	var rot_step := deg_to_rad(45)
	barrel_h.rotation += rot_step
	barrel_v.rotation += rot_step
	await barrel_h.animation_finished
	barrel_h.play("idle")
	barrel_v.play("idle")
	star.play("idle")
	angle_offset += deg_to_rad(45)
	fire_timer.start()

func _fire_volley() -> void:
	var dirs = [
		Vector2.RIGHT,
		Vector2.LEFT,
		Vector2.UP,
		Vector2.DOWN
	]
	for d in dirs:
		var b = bullet_scene.instantiate()
		get_parent().add_child(b)
		b.global_position = global_position
		var vel = d.rotated(angle_offset) * bullet_speed
		b.velocity = vel

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemy_bullet"):
		return
	if area.is_in_group("player_bullet") or (area.name.contains("Bullet") and not area.is_in_group("enemy_bullet")):
		hp -= 1
		if hp <= 0:
			_die()
		area.queue_free()

func _die() -> void:
	collision_shape.disabled = true
	queue_free()

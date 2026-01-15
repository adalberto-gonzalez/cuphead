extends Node2D

var positions: Array[Vector2] = [
	Vector2(0,0),
	Vector2(127.0, 18.0),
	Vector2(-300.0, 14.0),
	Vector2(-286.0, 44.0),
	Vector2(-249.0, 120.0),
	Vector2(63, 35)
]

@onready var spawner_4: Marker2D = $Spawners/Spawner_4
@onready var spawner_5: Marker2D = $Spawners/Spawner_5
@onready var spawner_6: Marker2D = $Spawners/Spawner_6
@onready var spawner_7: Marker2D = $Spawners/Spawner_7
@onready var spawner_8: Marker2D = $Spawners/Spawner_8
@onready var spawner_9: Marker2D = $Spawners/Spawner_9
var seed_cont = 0
var spawners
@onready var timer: Timer = $Timer
@onready var shooting_timer: Timer = $ShootingTimer
@onready var seed_timer: Timer = $seedTimer
@onready var anim: AnimatedSprite2D = $Anim
@onready var high_hitbox: CollisionShape2D = $HitboxHigh/CollisionShape2D
@onready var low_hitbox: CollisionShape2D = $HitboxLow/CollisionShape2D
@onready var hitbox: CollisionShape2D = $Hitbox/CollisionShape2D
@onready var spawner_1: Marker2D = $Spawners/Spawner_1
@onready var spawner_2: Marker2D = $Spawners/Spawner_2
@onready var spawner_3: Marker2D = $Spawners/Spawner_3

@export var player: Player

func _ready() -> void:
	anim.play("intro")
	spawners = [
		spawner_4.global_position,
		spawner_5.global_position,
		spawner_6.global_position,
		spawner_7.global_position,
		spawner_8.global_position,
		spawner_9.global_position
	]

func _on_anim_animation_finished() -> void:
	match(anim.animation):
		"in_firing":
			anim.play("firing")
			shooting_timer.start()
			seed_timer.start()
		"fn_firing":
			anim.position = positions[0]
			anim.play("idle")
		"in_high":
			anim.position = positions[4]
			anim.play("high")
			high_hitbox.set_deferred("disabled", false)
			hitbox.set_deferred("disabled", true)
		"in_low":
			anim.position = positions[4]
			anim.play("low")
			low_hitbox.set_deferred("disabled", false)
			hitbox.set_deferred("disabled", true)
		"in_obj":
			anim.play("obj")
			ObjectMaker.create_acorn(player.position, spawner_1.global_position)
			ObjectMaker.create_acorn(player.position, spawner_2.global_position)
			ObjectMaker.create_acorn(player.position, spawner_3.global_position)
		"obj":
			anim.play("fn_obj")
		"intro":
			anim.position = positions[0]
			anim.play("idle")
			timer.start()
		"fn_obj":
			anim.position = positions[0]
			anim.play("idle")
			timer.start()
		"high":
			anim.position = positions[0]
			anim.play("idle")
			timer.start()
			high_hitbox.set_deferred("disabled", true)
			hitbox.set_deferred("disabled", false)
		"low":
			anim.position = positions[0]
			anim.play("idle")
			timer.start()
			low_hitbox.set_deferred("disabled", true)
			hitbox.set_deferred("disabled", false)

func apply_hit():
	var tween = get_tree().create_tween()
	tween.tween_property(anim, "self_modulate", Color(1,1,1, 0.6), 0.06)
	tween.tween_property(anim, "self_modulate", Color(1,1,1, 1), 0.06)

func _on_area_2d_area_entered(area: Area2D) -> void:
	apply_hit()

func _on_timer_timeout() -> void:
	var idx = randi_range(0, 3)
	match(idx):
		0:
			anim.position = positions[1]
			print("Firing")
			anim.play("in_firing")
		1:
			anim.position = positions[2]
			print("High")
			anim.play("in_high")
		2:
			print("Low")
			anim.position = positions[3]
			anim.play("in_low")
		3:
			print("Obj")
			anim.position = positions[5]
			anim.play("in_obj")


func _on_shooting_timer_timeout() -> void:
	anim.play("fn_firing")
	timer.start()


func _on_seed_timer_timeout() -> void:
	if seed_cont < 5:
		var idx = randi_range(0, 5)
		seed_cont += 1
		seed_timer.start()
		if seed_cont % 2:
			ObjectMaker.create_chomper_seed(spawners[idx])
		else:
			ObjectMaker.create_flytrap_seed(spawners[idx])
	else:
		seed_cont = 0

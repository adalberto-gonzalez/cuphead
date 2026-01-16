extends StaticBody2D

@onready var damage_hitbox: CollisionShape2D = $DamageHitbox/CollisionShape2D
@onready var hornet_timer: Timer = $HornetTimer
@onready var hornet_timer_2: Timer = $HornetTimer2
@onready var mouth_timer: Timer = $MouthTimer
@onready var collision: CollisionShape2D = $Collision
@onready var hand: AnimatedSprite2D = $hand
@onready var hand_2: AnimatedSprite2D = $hand2
@onready var wall: AnimatedSprite2D = $Wall
@onready var wall_cover: AnimatedSprite2D = $WallCover
@onready var eye: AnimatedSprite2D = $eye
@onready var marker: Marker2D = $Marker
@onready var marker_2: Marker2D = $Marker2
@onready var close_timer: Timer = $CloseTimer
@onready var car_spawner: Marker2D = $CarSpawner
@onready var car_spawner_2: Marker2D = $CarSpawner2
@export var cam : Camera2D
var car = preload("res://scene/carro/carros_wall.tscn")
var car_2 = preload("res://scene/carro/carros_wall_upsidedown.tscn")
var full_cam = 19089
var lock_cam = 5600

@export var player: Player

enum HAND_STATE { IDLE, OPENING, CLOSING }

var hand_state := HAND_STATE.IDLE
var hand_2_state := HAND_STATE.IDLE

var alternate := false
var lives := 75
var player_in_range := false

func _ready() -> void:
	hand.visible = false
	hand_2.visible = false
	wall_cover.visible = false
	wall.play("idle")
	eye.play("idle")
	hornet_timer.start()
	hornet_timer_2.start()
	mouth_timer.start()

func _process(_delta: float) -> void:
	if lives <= 0:
		damage_hitbox.set_deferred("disabled", true)
		hand.visible = false
		hand_2.visible = false
		hand.stop()
		hand_2.stop()
		wall.play("death")
		hornet_timer.stop()
		hornet_timer_2.stop()
		mouth_timer.stop()
		close_timer.stop()
		wall_cover.visible = false
		eye.visible = false
		collision.disabled = true
		if cam != null:
			cam.limit_right = full_cam
	if player_in_range and cam != null and lives > 0:
		cam.limit_right = lock_cam
	elif cam != null:
		cam.limit_right = full_cam

# -------------------- DETECTOR --------------------

func _on_detector_area_entered(area: Area2D) -> void:
	if area.get_parent() is Player:
		player_in_range = true

func _on_detector_area_exited(area: Area2D) -> void:
	if area.get_parent() is Player:
		player_in_range = false

# -------------------- MANO 1 --------------------

func _on_hornet_timer_timeout() -> void:
	if lives <= 0 or hand_state != HAND_STATE.IDLE:
		return
	if not player_in_range:
		hornet_timer.start()
		return

	hand_state = HAND_STATE.OPENING
	hand.visible = true
	hand.play()

func _on_hand_animation_finished() -> void:
	match hand_state:
		HAND_STATE.OPENING:
			ObjectMaker.create_lips(player.position, marker.global_position)
			hand_state = HAND_STATE.CLOSING
			hand.play_backwards()

		HAND_STATE.CLOSING:
			hand.visible = false
			hand_state = HAND_STATE.IDLE
			hornet_timer.start()

# -------------------- MANO 2 --------------------

func _on_hornet_timer_2_timeout() -> void:
	if lives <= 0 or hand_2_state != HAND_STATE.IDLE:
		return
	if not player_in_range:
		hornet_timer_2.start()
		return

	hand_2_state = HAND_STATE.OPENING
	hand_2.visible = true
	hand_2.play()

func _on_hand_2_animation_finished() -> void:
	match hand_2_state:
		HAND_STATE.OPENING:
			ObjectMaker.create_lips(player.position, marker_2.global_position)
			hand_2_state = HAND_STATE.CLOSING
			hand_2.play_backwards()

		HAND_STATE.CLOSING:
			hand_2.visible = false
			hand_2_state = HAND_STATE.IDLE
			hornet_timer_2.start()

# -------------------- BOCA --------------------

func _on_mouth_timer_timeout() -> void:
	if alternate:
		wall.flip_v = true
		wall_cover.flip_v = true
	else:
		wall.flip_v = false
		wall_cover.flip_v = false

	wall.play("open_mouth")

func _on_wall_animation_finished() -> void:
	if wall.animation == "open_mouth":
		if player_in_range:
			if alternate:
				var car_instance = car_2.instantiate()
				car_instance.global_position = car_spawner_2.global_position
				get_tree().current_scene.add_child(car_instance)
			else:
				var car_instance = car.instantiate()
				car_instance.global_position = car_spawner.global_position
				get_tree().current_scene.add_child(car_instance)
		close_timer.start()
		wall.play("mouth_loop")
		wall_cover.visible = true
		wall_cover.play()
		alternate = !alternate

	elif wall.animation == "close_mouth":
		mouth_timer.start()
		wall.play("idle")

func _on_close_timer_timeout() -> void:
	wall_cover.stop()
	wall_cover.visible = false
	wall.play("close_mouth")


func _on_hitbox_area_entered(_area: Area2D) -> void:
	if lives <= 0:
		return

	lives -= 1
	eye.stop()
	eye.play("hurt")

extends Node2D

# Exported variables
@export var player: Player

# Position constants
var positions: Array[Vector2] = [
	Vector2(0, 0),
	Vector2(127.0, 18.0),
	Vector2(-300.0, 14.0),
	Vector2(-286.0, 44.0),
	Vector2(-249.0, 120.0),
	Vector2(63, 35),
	Vector2(249, 8),
	Vector2(171, 16),
	Vector2(96, 21)
]

# Animation nodes
@onready var anim: AnimatedSprite2D = $Anim
@onready var vines: AnimatedSprite2D = $Vines
@onready var platform_vines: AnimatedSprite2D = $Platform_Vines
@onready var platform_vines_2: AnimatedSprite2D = $Platform_Vines2
@onready var platform_vines_3: AnimatedSprite2D = $Platform_Vines3

# Hitbox nodes
@onready var hitbox: CollisionShape2D = $Hitbox/CollisionShape2D
@onready var high_hitbox: CollisionShape2D = $HitboxHigh/CollisionShape2D
@onready var low_hitbox: CollisionShape2D = $HitboxLow/CollisionShape2D
@onready var vine_hitbox_1: Area2D = $VineHitbox1
@onready var vine_hitbox_2: Area2D = $VineHitbox2
@onready var vine_hitbox_3: Area2D = $VineHitbox3

# Spawner nodes
@onready var spawner_1: Marker2D = $Spawners/Spawner_1
@onready var spawner_2: Marker2D = $Spawners/Spawner_2
@onready var spawner_3: Marker2D = $Spawners/Spawner_3
@onready var spawner_4: Marker2D = $Spawners/Spawner_4
@onready var spawner_5: Marker2D = $Spawners/Spawner_5
@onready var spawner_6: Marker2D = $Spawners/Spawner_6
@onready var spawner_7: Marker2D = $Spawners/Spawner_7
@onready var spawner_8: Marker2D = $Spawners/Spawner_8
@onready var spawner_9: Marker2D = $Spawners/Spawner_9
@onready var pollen_spawner: Marker2D = $PollenSpawner

# Timer nodes
@onready var timer: Timer = $Timer
@onready var shooting_timer: Timer = $ShootingTimer
@onready var platform_timer: Timer = $platformTimer
@onready var seed_timer: Timer = $seedTimer

# State variables
var death = false
var lives = 400
var second_phase = false
var seed_cont = 0
var spawners: Array
var active_vines: Array = []
var vine_platforms: Array
var vine_attack_in_progress = false
var vine_states: Dictionary = {} # Rastrea el estado de cada vine

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
	vine_platforms = [platform_vines, platform_vines_2, platform_vines_3]
	
	# Inicializar estados de vines
	vine_states = {0: "idle", 1: "idle", 2: "idle"}
	
	# Ocultar todas las vines al inicio
	platform_vines.visible = false
	platform_vines_2.visible = false
	platform_vines_3.visible = false
	
	# Desactivar hitboxes de vines al inicio
	vine_hitbox_1.monitoring = false
	vine_hitbox_1.monitorable = false
	vine_hitbox_2.monitoring = false
	vine_hitbox_2.monitorable = false
	vine_hitbox_3.monitoring = false
	vine_hitbox_3.monitorable = false
	
	# Desactivar collision shapes de vines
	for vine_hitbox in [vine_hitbox_1, vine_hitbox_2, vine_hitbox_3]:
		for child in vine_hitbox.get_children():
			if child is CollisionShape2D:
				child.disabled = true
	
	# Conectar señales de animación (solo si no están conectadas)
	if not vines.animation_finished.is_connected(_on_vines_animation_finished):
		vines.animation_finished.connect(_on_vines_animation_finished)
	if not platform_vines.animation_finished.is_connected(_on_platform_vines_animation_finished):
		platform_vines.animation_finished.connect(_on_platform_vines_animation_finished)
	if not platform_vines_2.animation_finished.is_connected(_on_platform_vines_2_animation_finished):
		platform_vines_2.animation_finished.connect(_on_platform_vines_2_animation_finished)
	if not platform_vines_3.animation_finished.is_connected(_on_platform_vines_3_animation_finished):
		platform_vines_3.animation_finished.connect(_on_platform_vines_3_animation_finished)
	if not anim.animation_finished.is_connected(_on_anim_animation_finished):
		anim.animation_finished.connect(_on_anim_animation_finished)
	
	# Conectar señales de timers
	if not timer.timeout.is_connected(_on_timer_timeout):
		timer.timeout.connect(_on_timer_timeout)
	if not shooting_timer.timeout.is_connected(_on_shooting_timer_timeout):
		shooting_timer.timeout.connect(_on_shooting_timer_timeout)
	if not seed_timer.timeout.is_connected(_on_seed_timer_timeout):
		seed_timer.timeout.connect(_on_seed_timer_timeout)
	if not platform_timer.timeout.is_connected(_on_platform_timer_timeout):
		platform_timer.timeout.connect(_on_platform_timer_timeout)

func _process(delta: float) -> void:
	if lives < 0:
		lives = 0
		hitbox.set_deferred("disabled", true)
		handle_death()
	elif lives <= 180 and not second_phase:
		start_second_phase()

func start_second_phase() -> void:
	second_phase = true
	vines.visible = true
	low_hitbox.set_deferred("disabled", false)
	
	# Detener timers de fase 1
	timer.stop()
	shooting_timer.stop()
	seed_timer.stop()
	
	# Resetear contador de semillas
	seed_cont = 0
	
	# Cambiar a animación final
	anim.position = positions[6]
	anim.play("in_final")
	vines.play("intro")

func apply_hit() -> void:
	lives -= 1
	var tween = get_tree().create_tween()
	tween.tween_property(anim, "self_modulate", Color(1, 1, 1, 0.6), 0.06)
	tween.tween_property(anim, "self_modulate", Color(1, 1, 1, 1), 0.06)

func execute_phase_one_attack(attack_idx: int) -> void:
	match attack_idx:
		0: # Firing
			anim.position = positions[1]
			anim.play("in_firing")
		1: # High
			anim.position = positions[5]
			anim.play("in_obj")
		2: # Low
			anim.position = positions[3]
			anim.play("in_low")
		3: # Object
			anim.position = positions[5]
			anim.play("in_obj")

func activate_random_vines() -> void:
	vine_attack_in_progress = true
	
	# Desactivar todas las vines primero
	deactivate_all_vines()
	
	# Seleccionar 2 vines aleatorias
	var available_indices = [0, 1, 2]
	available_indices.shuffle()
	active_vines = [available_indices[0], available_indices[1]]
	
	# Activar las vines seleccionadas con delay
	for i in range(active_vines.size()):
		var idx = active_vines[i]
		var vine = vine_platforms[idx]
		
		if i == 0:
			# Primera vine aparece inmediatamente
			vine.visible = true
			vine_states[idx] = "intro"
			vine.play("intro")
			platform_timer.start()
		else:
			# Segunda vine aparece 1 segundo después
			await get_tree().create_timer(1.0).timeout
			vine.visible = true
			vine_states[idx] = "intro"
			vine.play("intro")

func deactivate_all_vines() -> void:
	for i in range(vine_platforms.size()):
		var vine = vine_platforms[i]
		if vine.is_playing():
			vine.stop()
		vine.visible = false
		vine_states[i] = "idle"
		disable_vine_hitbox(i)

func handle_vine_animation_finished(vine: AnimatedSprite2D, vine_idx: int) -> void:
	var state = vine_states[vine_idx]
	
	match state:
		"intro":
			vine.play("idle")
			vine_states[vine_idx] = "active"
			enable_vine_hitbox(vine_idx)
		
		"active":
			disable_vine_hitbox(vine_idx)
			vine.play_backwards("idle")
			vine_states[vine_idx] = "idle_back"
		
		"idle_back":
			vine.play_backwards("intro")
			vine_states[vine_idx] = "intro_back"
		
		"intro_back":
			vine.visible = false
			vine_states[vine_idx] = "idle"
			
			# Verificar si todas las vines activas terminaron
			var all_finished = true
			for idx in active_vines:
				if vine_platforms[idx].visible:
					all_finished = false
					break
			
			if all_finished:
				vine_attack_in_progress = false
				platform_timer.start()

func enable_vine_hitbox(vine_idx: int) -> void:
	match vine_idx:
		0: 
			vine_hitbox_1.monitoring = true
			vine_hitbox_1.monitorable = true
			# Activar collision shapes dentro del Area2D
			for child in vine_hitbox_1.get_children():
				if child is CollisionShape2D:
					child.disabled = false
		1: 
			vine_hitbox_2.monitoring = true
			vine_hitbox_2.monitorable = true
			for child in vine_hitbox_2.get_children():
				if child is CollisionShape2D:
					child.disabled = false
		2: 
			vine_hitbox_3.monitoring = true
			vine_hitbox_3.monitorable = true
			for child in vine_hitbox_3.get_children():
				if child is CollisionShape2D:
					child.disabled = false

func disable_vine_hitbox(vine_idx: int) -> void:
	match vine_idx:
		0: 
			vine_hitbox_1.monitoring = false
			vine_hitbox_1.monitorable = false
			# Desactivar collision shapes dentro del Area2D
			for child in vine_hitbox_1.get_children():
				if child is CollisionShape2D:
					child.disabled = true
		1: 
			vine_hitbox_2.monitoring = false
			vine_hitbox_2.monitorable = false
			for child in vine_hitbox_2.get_children():
				if child is CollisionShape2D:
					child.disabled = true
		2: 
			vine_hitbox_3.monitoring = false
			vine_hitbox_3.monitorable = false
			for child in vine_hitbox_3.get_children():
				if child is CollisionShape2D:
					child.disabled = true

func execute_phase_two_attack() -> void:
	var attack_choice = randi_range(0, 1)
	
	if attack_choice == 0 and !vine_attack_in_progress and !death:
		activate_random_vines()
	elif !death:
		anim.play("in_pollen")

# Signal handlers
func _on_area_2d_area_entered(area: Area2D) -> void:
	apply_hit()

func _on_timer_timeout() -> void:
	if not second_phase:
		var idx = randi_range(0, 3)
		execute_phase_one_attack(idx)

func _on_shooting_timer_timeout() -> void:
	if not second_phase:
		anim.play("fn_firing")
		timer.start()

func _on_seed_timer_timeout() -> void:
	if not second_phase and seed_cont < 5:
		var idx = randi_range(0, 5)
		seed_cont += 1
		seed_timer.start()
		
		if seed_cont % 2:
			ObjectMaker.create_chomper_seed(spawners[idx])
		else:
			ObjectMaker.create_flytrap_seed(spawners[idx])
	elif not second_phase:
		seed_cont = 0

func _on_platform_timer_timeout() -> void:
	if second_phase:
		execute_phase_two_attack()

func _on_vines_animation_finished() -> void:
	if vines.animation == "intro":
		vines.play("idle")

func _on_platform_vines_animation_finished() -> void:
	handle_vine_animation_finished(platform_vines, 0)

func _on_platform_vines_2_animation_finished() -> void:
	handle_vine_animation_finished(platform_vines_2, 1)

func _on_platform_vines_3_animation_finished() -> void:
	handle_vine_animation_finished(platform_vines_3, 2)

func _on_anim_animation_finished() -> void:
	match anim.animation:
		"intro":
			if not second_phase:
				anim.position = positions[0]
				anim.play("idle")
				timer.start()
		
		"in_final":
			anim.play("final")
			platform_timer.start()
			anim.position = positions[7]
		
		"final":
			pass
		
		"in_firing":
			if not second_phase:
				anim.play("firing")
				shooting_timer.start()
				seed_timer.start()
		
		"fn_firing":
			if not second_phase:
				anim.position = positions[0]
				anim.play("idle")
		
		"in_high":
			if not second_phase:
				anim.position = positions[4]
				anim.play("high")
				high_hitbox.set_deferred("disabled", false)
				hitbox.set_deferred("disabled", true)
		
		"high":
			if not second_phase:
				anim.position = positions[0]
				anim.play("idle")
				timer.start()
				high_hitbox.set_deferred("disabled", true)
				hitbox.set_deferred("disabled", false)
		
		"in_low":
			if not second_phase:
				anim.position = positions[4]
				anim.play("low")
				low_hitbox.set_deferred("disabled", false)
				hitbox.set_deferred("disabled", true)
		
		"low":
			if not second_phase:
				anim.position = positions[0]
				anim.play("idle")
				timer.start()
				low_hitbox.set_deferred("disabled", true)
				hitbox.set_deferred("disabled", false)
		
		"in_obj":
			if not second_phase:
				anim.play("obj")
				ObjectMaker.create_acorn(player.position, spawner_1.global_position)
				ObjectMaker.create_acorn(player.position, spawner_2.global_position)
				ObjectMaker.create_acorn(player.position, spawner_3.global_position)
		
		"obj", "fn_obj":
			if not second_phase:
				anim.position = positions[0]
				anim.play("idle")
				timer.start()
		
		"in_pollen":
			anim.play("fn_pollen")
			ObjectMaker.create_pollen(pollen_spawner.global_position)

		"fn_pollen":
			if second_phase:
				anim.position = positions[7]
				anim.play("final")
				platform_timer.start()

func handle_death() -> void:
	death = true
	low_hitbox.set_deferred("disabled",true)
	anim.position = positions[8]
	anim.play("death")
	hitbox.set_deferred("disabled",true)
	SignalManager.boss_killed.emit()
	platform_timer.stop()

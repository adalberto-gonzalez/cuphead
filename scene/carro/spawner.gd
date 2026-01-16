extends Node2D
@onready var timer: Timer = $Timer
@onready var up_marker: Marker2D = $Up
var cars = preload("res://scene/carro/carros.tscn")
var cars_ud = preload("res://scene/carro/carros_upsidedown.tscn")
var duck = preload("res://scene/carro/duck.tscn")
var duck_ud = preload("res://scene/carro/duck_upsidedown.tscn")
var spawn_pair = 0  # 0 = primera pareja, 1 = segunda pareja
var on_area = false
var has_spawned_on_enter = false

func _ready() -> void:
	timer.start()
	spawn_current_pair()

func _on_timer_timeout() -> void:
	if on_area:
		spawn_current_pair()

func spawn_current_pair() -> void:
	if spawn_pair == 0:
		# Primera pareja: cars_ud en up_marker Y duck en global_position
		var car_instance = cars_ud.instantiate()
		car_instance.global_position = up_marker.global_position
		get_tree().current_scene.add_child(car_instance)
		
		var duck_instance = duck.instantiate()
		duck_instance.global_position = global_position
		get_tree().current_scene.add_child(duck_instance)
		
		spawn_pair = 1
	else:
		# Segunda pareja: cars en global_position Y duck_ud en up_marker
		var car_instance = cars.instantiate()
		car_instance.global_position = global_position
		get_tree().current_scene.add_child(car_instance)
		
		var duck_instance = duck_ud.instantiate()
		duck_instance.global_position = up_marker.global_position
		get_tree().current_scene.add_child(duck_instance)
		
		spawn_pair = 0

func _on_area_2d_area_entered(area: Area2D) -> void:
	on_area = true
	if not has_spawned_on_enter:
		spawn_current_pair()
		has_spawned_on_enter = true

func _on_area_2d_area_exited(area: Area2D) -> void:
	on_area = false
	has_spawned_on_enter = false

extends Node
var player_bullet = preload("res://scene/bullets/peashooter/bullet.tscn")
var lips = preload("uid://btre2efqsj3po")
var acorn = preload("res://scene/enemies/Cagney/acorn.tscn")
var chomper = preload("res://scene/cagneyCarnation/seeds/chomper.tscn")
var flytrap = preload("res://scene/cagneyCarnation/seeds/flytrap.tscn")
var vine = preload("res://scene/cagneyCarnation/seeds/vine.tscn")
var chomper_seed = preload("res://scene/cagneyCarnation/seeds/chomper_seed.tscn")
var flytrap_seed = preload("res://scene/cagneyCarnation/seeds/flytrap_seed.tscn")
var pollen = preload("res://scene/enemies/Cagney/pollen.tscn")

func create_player_bullet(dir: Vector2, marker_pos: Vector2):
	var new_bullet = player_bullet.instantiate()
	new_bullet.global_position = marker_pos # + Vector2(randf_range(-25,25), randf_range(-25,25))
	var target_point = marker_pos + dir
	
	get_tree().get_current_scene().add_child(new_bullet)
	new_bullet.set_bullet_direction(target_point)

func create_lips(target_pos: Vector2, marker_pos: Vector2):
	var new_bullet = lips.instantiate()
	new_bullet.global_position = marker_pos

	get_tree().current_scene.add_child(new_bullet)
	new_bullet.set_bullet_direction(target_pos)

func create_acorn(target_pos: Vector2, marker_pos: Vector2):
	var new_bullet = acorn.instantiate()
	new_bullet.global_position = marker_pos

	get_tree().current_scene.add_child(new_bullet)
	new_bullet.set_bullet_direction(target_pos)

func create_chomper(pos: Vector2):
	var chomper = chomper.instantiate()
	chomper.global_position = pos
	get_tree().current_scene.add_child(chomper)

func create_vine(pos: Vector2):
	var vine = vine.instantiate()
	vine.global_position = pos
	get_tree().current_scene.add_child(vine)
	
func create_flytrap(pos: Vector2):
	var flytrap = flytrap.instantiate()
	flytrap.global_position = pos
	get_tree().current_scene.add_child(flytrap)

func create_chomper_seed(pos: Vector2):
	var chomper = chomper_seed.instantiate()
	chomper.global_position = pos
	get_tree().current_scene.add_child(chomper)

func create_flytrap_seed(pos: Vector2):
	var flytrap = flytrap_seed.instantiate()
	flytrap.global_position = pos
	get_tree().current_scene.add_child(flytrap)

func create_pollen(pos: Vector2):
	var pollen = pollen.instantiate()
	pollen.global_position = pos
	get_tree().current_scene.add_child(pollen)

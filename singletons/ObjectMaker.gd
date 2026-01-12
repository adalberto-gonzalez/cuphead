extends Node
var player_bullet = preload("res://scene/bullets/peashooter/bullet.tscn")

func create_player_bullet(dir: Vector2, marker_pos: Vector2):
	var new_bullet = player_bullet.instantiate()
	new_bullet.global_position = marker_pos # + Vector2(randf_range(-25,25), randf_range(-25,25))
	var target_point = marker_pos + dir
	
	get_tree().get_current_scene().add_child(new_bullet)
	new_bullet.set_bullet_direction(target_point)

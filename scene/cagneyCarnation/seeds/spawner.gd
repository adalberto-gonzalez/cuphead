extends Node2D

func _ready() -> void:
	var seed_position = Vector2.ZERO
	seed_position = global_position + Vector2(randf_range(0, 200), randf_range(0, 200))
	ObjectMaker.create_chomper_seed(seed_position)
	seed_position = position + Vector2(randf_range(200, 400), randf_range(0, 200))
	ObjectMaker.create_chomper_seed(seed_position)
	seed_position = position + Vector2(randf_range(400, 600), randf_range(0, 200))
	ObjectMaker.create_chomper_seed(seed_position)
	seed_position = position + Vector2(randf_range(600, 800), randf_range(0, 200))
	ObjectMaker.create_chomper_seed(seed_position)
	seed_position = position + Vector2(randf_range(0, 700), randf_range(0, 200))
	ObjectMaker.create_chomper_seed(seed_position)
	print(seed_position)

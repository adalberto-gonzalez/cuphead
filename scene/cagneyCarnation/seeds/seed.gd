extends Area2D

@onready var seed: AnimatedSprite2D = $seed
@onready var spawn: AnimatedSprite2D = $Spawn
var on_land := false

func _ready() -> void:
	spawn.visible = false
	seed.play("fall")

func _process(delta: float) -> void:
	if !on_land:
		position.y += 200 * delta
	
func _on_body_entered(area: Node2D) -> void:
	seed.play("land")
	on_land = true

func _on_seed_animation_finished() -> void:
	spawn.visible = true
	spawn.play("spawn")

func _on_spawn_animation_finished() -> void:
	if spawn.animation == "spawn":
		spawner()
		seed.visible = true
		spawn.play("dust")
	else:
		queue_free()

func spawner():
	pass

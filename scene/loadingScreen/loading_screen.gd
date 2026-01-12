extends Control

@export var next_scene_path: String
@onready var timer: Timer = $Timer
var status

func _ready():
	timer.start()
	if SceneTransition.next_scene_path != "":
		ResourceLoader.load_threaded_request(SceneTransition.next_scene_path)

func _process(_delta):
	var progress := []
	status = ResourceLoader.load_threaded_get_status(
		SceneTransition.next_scene_path,
		progress
	)

func _on_timer_timeout() -> void:
	if status == ResourceLoader.THREAD_LOAD_LOADED:
		var scene = ResourceLoader.load_threaded_get(SceneTransition.next_scene_path)
		get_tree().change_scene_to_packed(scene)

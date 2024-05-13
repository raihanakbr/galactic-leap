extends Area2D

@export var speed = 2000

func _ready():
	set_as_top_level(true)

func _process(delta):
	position += (Vector2.RIGHT * speed).rotated(rotation) * delta

func _physics_process(delta):
	await get_tree().create_timer(0.01).timeout
	set_physics_process(false)

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

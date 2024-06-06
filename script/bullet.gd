extends Area2D

@export var speed = 2000
signal enemy_hit(score)

func _ready():
	set_as_top_level(true)

func _process(delta):
	position += (Vector2.RIGHT * speed).rotated(rotation) * delta

func _physics_process(_delta):
	await get_tree().create_timer(0.01).timeout
	set_physics_process(false)

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

func _on_body_entered(body):
	if body.is_in_group("boss"):
		print("is this it")
		queue_free()
		enemy_hit.emit(400)

func _on_area_entered(area):
	if area.is_in_group("obstacle"):
		queue_free()

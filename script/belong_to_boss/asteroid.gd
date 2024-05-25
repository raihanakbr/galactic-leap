extends Area2D

signal crash()

@export var speed = 400

var health = 2

func _ready():
	set_as_top_level(true)

func _process(delta):
	position += (Vector2.RIGHT * speed).rotated(rotation) * delta

func _on_body_entered(body):
	if body.is_in_group("boss_platform"):
		emit_signal("crash")
		queue_free()
	
	if body.is_in_group("player"):
		#Player death
		get_tree().reload_current_scene()

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

func _on_area_entered(area):
	if area.is_in_group("bullet"):
		health -= 1
		if health == 0:
			queue_free()
	pass # Replace with function body.

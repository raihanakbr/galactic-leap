extends Area2D

@export var speed = 2000

signal enemy_hit(score)

var particle = preload("res://scene/particles/blood.tscn")

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
		particle.instantiate()
		enemy_hit.emit(400)
		_destroy()
	elif body.is_in_group("enemy"):
		body.take_damage()
		enemy_hit.emit(100)
		particle.instantiate()
		_destroy()

func _on_area_entered(area):
	if area.is_in_group("obstacle"):
		queue_free()
		
func _destroy() -> void:
	var _particle_instance = particle.instantiate()
	_particle_instance.global_position = global_position - (Vector2.RIGHT * 25).rotated(rotation)
	_particle_instance.rotation = global_rotation
	_particle_instance.set_as_top_level(true)
	get_tree().current_scene.add_child(_particle_instance)
	_particle_instance.emitting = true
	queue_free()

extends Area2D

signal crash()

@export var speed = 400
@onready var anim = $AnimatedSprite2D
@onready var collision = $CollisionShape2D
@onready var hurt_sfx = $AudioStreamPlayer2D
var death_particle = preload("res://scene/particles/asteroid_destroyed.tscn")

var health = 2
var can_be_deleted = false
var can_move = false
var direction
var facing_dir #-1 Right, 1 Left

func _ready():
	set_as_top_level(true)
	anim.play("default")
	collision.position.x *= facing_dir
	anim.flip_h = facing_dir == -1

func _process(delta):
	if direction != null:
		position += (Vector2.RIGHT * speed).rotated(direction) * delta

func _on_body_entered(body):
	if body.is_in_group("boss_platform"):
		emit_signal("crash")
		_destroy()
	
	if body.is_in_group("player"):
		body.player_death()

func _on_visible_on_screen_notifier_2d_screen_exited():
	if can_be_deleted:
		queue_free()

func _on_area_entered(area):
	if area.is_in_group("bullet"):
		health -= 1
		hurt_sfx.play()
		if health == 0:
			_destroy()

func _on_visible_on_screen_notifier_2d_screen_entered():
	can_be_deleted = true

func _destroy() -> void:
	var _particle = death_particle.instantiate()
	_particle.position = global_position
	_particle.rotation = global_rotation
	get_tree().current_scene.add_child(_particle)
	_particle.emitting = true
	
	queue_free()

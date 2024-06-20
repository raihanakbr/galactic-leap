extends Area2D

signal crash()

@export var speed = 400
@onready var collision = $CollisionShape2D
@onready var anim_player = $AnimationPlayer
@onready var hurt_sound = $AudioStreamPlayer2D
var death_particle = preload("res://scene/particles/ball_destroyed.tscn")

var health = 2
var can_be_deleted = false
var can_move = false

func _ready():
	set_as_top_level(true)
	anim_player.play("glitch")

func _process(delta):
	if can_move:
		position += (Vector2.RIGHT * speed).rotated(rotation) * delta

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
	if area.is_in_group("bullet") and can_move:
		health -= 1
		hurt_sound.play()
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
	
func enable_movement() -> void:
	can_move = true

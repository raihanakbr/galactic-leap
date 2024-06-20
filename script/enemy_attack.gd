extends Area2D

@onready var anim_player = $AnimationPlayer
@onready var attack_sound = $AudioStreamPlayer2D
@export var speed = 600
var can_move = false

func _ready():
	set_as_top_level(true)
	anim_player.play("ready")

func _process(delta):
	if can_move:
		position += (Vector2.RIGHT * speed).rotated(rotation) * delta

func _physics_process(_delta):
	await get_tree().create_timer(0.01).timeout
	set_physics_process(false)

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

func _on_body_entered(body):
	if body.is_in_group("player"):
		body.player_death()
		
func enable_movement() -> void:
	can_move = true
	attack_sound.play()

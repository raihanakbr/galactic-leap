extends Sprite2D

signal add_score(score)

@onready var character_sprite = $"../Sprite2D"
@onready var gunshot = $AudioStreamPlayer2D

var can_fire = true
var bullet = preload("res://scene/bullet.tscn")
var can_move = true

# Called when the node enters the scene tree for the first time.
func _ready():
	set_as_top_level(true)
	pass # Replace with function body.

func _process(_delta):
	if not can_move:
		return
		
	var mouse_pos = get_global_mouse_position()
	look_at(mouse_pos)

	if character_sprite.frame == 0:
		frame = 0
		position.x = get_parent().position.x - 22
		position.y = get_parent().position.y + 7
		flip_v = true
	elif character_sprite.frame == 3:
		frame = 0
		position.x = get_parent().position.x + 22
		position.y = get_parent().position.y + 7
		flip_v = false
	elif character_sprite.frame == 2:
		frame = 1
		position.x = get_parent().position.x - 11
		position.y = get_parent().position.y - 15
		flip_v = true
	elif character_sprite.frame == 5:
		frame = 1
		position.x = get_parent().position.x + 11
		position.y = get_parent().position.y - 15
		flip_v = false

func _physics_process(_delta):
	if not can_move:
		return	

	if Input.is_action_pressed("fire") and can_fire:
		gunshot.play()
		var bullet_instance = bullet.instantiate()
		bullet_instance.enemy_hit.connect(enemy_hit)
		bullet_instance.rotation = rotation
		bullet_instance.global_position = $Marker2D.global_position
		get_parent().add_child(bullet_instance)
		can_fire = false
		await get_tree().create_timer(0.2).timeout
		can_fire = true

func enemy_hit(score):
	add_score.emit(score)

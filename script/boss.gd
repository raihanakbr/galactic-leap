extends StaticBody2D

@onready var eye = $Sprite2D3
@onready var anim = $AnimatedSprite2D
@onready var anim_player = $AnimationPlayer

signal end_phase()
signal additional_score(num)
signal apply_shake()
signal platform_attack()
signal attack_completed

var current_level
var player
var platform_y_pos

var asteroid = preload("res://scene/belong_to_boss/asteroid.tscn")
var normal_ball = preload("res://scene/belong_to_boss/normal_attack.tscn")
var glitch_effect = preload("res://scene/particles/glitch_effect.tscn")

#Progression
#Behavior 1
var _attack_count_1 = 2
var _interval

#Behavior 2
var _attack_phase_count = 2
var _cooldown = 4

#Behavior 3
var _attack_count_3 = 2
var _shower_count = 10

func _ready() -> void:
	set_as_top_level(true)
	anim_player.play("ready")
	pass
	
func _physics_process(_delta: float) -> void:
	pass
	
func start(player_node, level) -> void:
	current_level = level
	level = level % 3
	eye.player = player_node
	await get_tree().create_timer(4).timeout
	player = player_node
	if level == 0:
		await behavior_one()
	elif level == 1:
		await behavior_two()
	elif level == 2:
		await behavior_three()
	anim_player.play("end")
		
func behavior_one() -> void:
	for i in range(_attack_count_1):
		await normal_attack(10)
		await get_tree().create_timer(3).timeout
	_attack_count_1 += 1
	_attack_count_1 = min(_attack_count_1, 5)
	
func behavior_two() -> void:
	platform_attack.emit()
	await get_tree().create_timer(4).timeout
	for i in range(_attack_phase_count):
		await normal_attack(3)
		await get_tree().create_timer(_cooldown).timeout
	await attack_completed
	_attack_phase_count += 1
	_attack_phase_count = min(5, _attack_phase_count)
	_cooldown -= 0.5
	_cooldown = min(2.5, _cooldown)
	
func behavior_three() -> void:
	for i in range(_attack_count_3):
		anim.set_frame_and_progress(0, 0.0)
		anim.play()
		await get_tree().create_timer(3).timeout
		await asteroid_shower(_shower_count)
	if current_level >= 10:
		_attack_count_3 += 1
	_attack_count_3 = min(4, _attack_count_3)
	_shower_count += 1
	_shower_count = min(18, _shower_count)

func asteroid_shower(num: int) -> void:
	for i in range(num):
		var spawn_side = randi_range(0, 1)
		var spawn_x
		var direction_x
		var facing_dir
		
		if spawn_side == 0: #left
			spawn_x = randf_range(355, 405)
			direction_x = randf_range(5, 155)
			facing_dir = 1
			
		else: #right
			spawn_x = randf_range(-95, -45)
			direction_x = randf_range(155, 305)
			facing_dir = -1
		await spawn_asteroid(Vector2(spawn_x, global_position.y), Vector2(direction_x, platform_y_pos), facing_dir)
	await get_tree().create_timer(3).timeout

func create_glitch_effect() -> void:
	var glitch_instance = glitch_effect.instantiate()
	glitch_instance.global_position = global_position + Vector2(0, 160)
	glitch_instance.set_as_top_level(true)
	get_parent().add_child(glitch_instance)
	glitch_instance.play()
	await get_tree().create_timer(1).timeout
	glitch_instance.queue_free()

func normal_attack(num: int) -> void:
	create_glitch_effect()
	await get_tree().create_timer(0.5).timeout
	for i in range(num):
		var ball_instance = normal_ball.instantiate()
		ball_instance.global_position = global_position + Vector2(0, 160)
		ball_instance.look_at(player.position)
		ball_instance.crash.connect(apply_camera_shake)
		get_parent().add_child(ball_instance)
		get_parent().move_child(ball_instance, 0)
		await get_tree().create_timer(0.3).timeout
		
func spawn_asteroid(position: Vector2, direction: Vector2, facing_dir: int) -> void:
	var asteroid_instance = asteroid.instantiate()
	asteroid_instance.global_position = position
	asteroid_instance.look_at(direction)
	asteroid_instance.direction = asteroid_instance.rotation
	asteroid_instance.rotation = 0
	asteroid_instance.facing_dir = facing_dir
	asteroid_instance.crash.connect(apply_camera_shake)
	get_parent().add_child(asteroid_instance)
	await get_tree().create_timer(0.8).timeout
	
func apply_camera_shake() -> void:
	apply_shake.emit()

func _on_animated_sprite_2d_animation_looped():
	anim.stop()

func end() -> void:
	await get_tree().create_timer(2).timeout
	end_phase.emit()
	queue_free()

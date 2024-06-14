extends StaticBody2D

signal end_phase()
signal additional_score(num)
signal apply_shake()
signal platform_attack()
signal attack_completed

var current_level
var player
var platform_y_pos

var asteroid = preload("res://scene/belong_to_boss/asteroid.tscn")
var asteroid_bomb = preload("res://scene/belong_to_boss/asteroid_bomb.tscn")

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
	pass
	
func _physics_process(_delta: float) -> void:
	pass
	
func start(player_node, level) -> void:
	current_level = level
	await get_tree().create_timer(2).timeout
	player = player_node
	if level == 0:
		await behavior_one()
	elif level == 1:
		await behavior_two()
	elif level == 2:
		await behavior_three()
	level += 1
	level = level % 3
	await get_tree().create_timer(1).timeout
	queue_free()
		
func behavior_one() -> void:
	for i in range(_attack_count_1):
		await asteroid_attack(10)
		await get_tree().create_timer(3).timeout
	_attack_count_1 += 1
	_attack_count_1 = min(_attack_count_1, 5)
	
func behavior_two() -> void:
	platform_attack.emit()
	await get_tree().create_timer(4).timeout
	for i in range(_attack_phase_count):
		await asteroid_attack(3)
		await get_tree().create_timer(_cooldown).timeout
	await attack_completed
	_attack_phase_count += 1
	_attack_phase_count = min(5, _attack_phase_count)
	_cooldown -= 0.5
	_cooldown = min(2.5, _cooldown)
	
func behavior_three() -> void:
	for i in range(_attack_count_3):
		await asteroid_shower(_shower_count)
	await get_tree().create_timer(3).timeout
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
		
		if spawn_side == 0: #left
			spawn_x = randf_range(355, 405)
			direction_x = randf_range(5, 155)
			
		else: #right
			spawn_x = randf_range(-95, -45)
			direction_x = randf_range(155, 305)
		await spawn_asteroid(Vector2(spawn_x, global_position.y), Vector2(direction_x, platform_y_pos))
	await get_tree().create_timer(3).timeout

func asteroid_attack(num: int) -> void:
	for i in range(num):
		var asteroid_instance = asteroid.instantiate()
		asteroid_instance.global_position = global_position
		asteroid_instance.look_at(player.position)
		asteroid_instance.crash.connect(apply_camera_shake)
		get_parent().add_child(asteroid_instance)
		await get_tree().create_timer(0.3).timeout
		
func spawn_asteroid(position: Vector2, direction: Vector2) -> void:
	var asteroid_instance = asteroid.instantiate()
	asteroid_instance.global_position = position
	asteroid_instance.look_at(direction)
	asteroid_instance.crash.connect(apply_camera_shake)
	get_parent().add_child(asteroid_instance)
	await get_tree().create_timer(0.8).timeout
	
func apply_camera_shake() -> void:
	apply_shake.emit()

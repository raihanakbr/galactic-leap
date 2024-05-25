extends StaticBody2D

signal end_phase()
signal additional_score(num)
signal apply_shake()
signal platform_attack()
signal attack_completed

var level = 1
var player

var asteroid = preload("res://scene/belong_to_boss/asteroid.tscn")

func _ready() -> void:
	set_as_top_level(true)
	pass
	
func _physics_process(_delta: float) -> void:
	#print(player)
	pass
	
func start(player_node) -> void:
	await get_tree().create_timer(2).timeout
	player = player_node
	if level == 1:
		await behavior_one()
	if level >= 2:
		await behavior_two()
	level += 1
	await get_tree().create_timer(1).timeout
	#emit_signal("end_phase")
	queue_free()
		
func behavior_one() -> void:
	for i in range(2):
		await asteroid_attack(10)
		await get_tree().create_timer(3).timeout
	
func behavior_two() -> void:
	platform_attack.emit()
	await get_tree().create_timer(4).timeout
	for i in range(4):
		await asteroid_attack(2)
		await get_tree().create_timer(4).timeout
	await attack_completed

func asteroid_attack(num: int) -> void:
	for i in range(num):
		var asteroid_instance = asteroid.instantiate()
		asteroid_instance.global_position = global_position
		asteroid_instance.look_at(player.position)
		asteroid_instance.crash.connect(apply_camera_shake)
		get_parent().add_child(asteroid_instance)
		await get_tree().create_timer(0.3).timeout
		print(player.position)
		
func apply_camera_shake() -> void:
	emit_signal("apply_shake")

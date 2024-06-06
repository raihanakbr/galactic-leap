extends Node2D

@onready var player = $Player
@onready var camera = $Camera2D
@onready var score_label = $Camera2D/Score
@onready var camera_init_y_pos = $Camera2D.position.y
@onready var platform_container = $platform_container
@onready var platform_y_pos = $platform_container/platform.position.y
@export var scene_platform:Array[PackedScene]

# How quickly to move through the noise
@export var NOISE_SHAKE_SPEED: float = 30.0
@export var NOISE_SWAY_SPEED: float = 1.0
# Multiplier for lerping the shake strength to zero
@export var SHAKE_DECAY_RATE: float = 3.0
# The starting range of possible offsets using random values
@export var RANDOM_SHAKE_STRENGTH: float = 30.0

@onready var noise := FastNoiseLite.new()
# Used to keep track of where we are in the noise
# so that we can smoothly move through it
var noise_i: float = 0.0
@onready var rand = RandomNumberGenerator.new()
var shake_strength: float = 0.0

var boss = preload("res://scene/boss.tscn")
var boss_instance
var boss_platform
var left_platform
var right_platform

var score = 0
#var additional_score = 0

var target_score_for_boss = 1
var score_needed_between_boss = 14000
var boss_position

var last_platform_is_trap = false
var player_is_above = true
var to_boss_fight = false
var boss_fighting = false

func _ready() -> void:
	level_generator(20)

func _physics_process(_delta: float) -> void:
	score_update()
	if not boss_fighting:
		if player.position.y < camera.position.y:
			camera.position.y = player.position.y
			player_is_above = true
		else:
			player_is_above = false
	
func _process(delta: float) -> void:
	process_camera_shake(delta)

	if not player_is_above and not boss_fighting:
		camera.position.y -= 1
		
	if score >= target_score_for_boss and not to_boss_fight:
		to_boss_fight = true
		generate_platform_on_boss()

func generate_platform_on_boss() -> void:
	platform_y_pos -= randf_range(60, 80)
	boss_platform = scene_platform[3].instantiate() as StaticBody2D
	boss_platform.position = Vector2(180, platform_y_pos)
	platform_container.call_deferred("add_child", boss_platform)

func level_generator(amount: int) -> void:
	for i in amount:
		var random_num = randi_range(0, 5)
		platform_y_pos -= randf_range(60, 80)
		var new_platform
		
		if not last_platform_is_trap and random_num < 2:
			new_platform = scene_platform[2].instantiate() as StaticBody2D
			last_platform_is_trap = true
			new_platform.connect("delete_broken_platform", delete_broken_platform)
		else:
			if random_num == 3 and abs(score - target_score_for_boss) > 3000:
				new_platform = scene_platform[1].instantiate() as StaticBody2D
			else:
				new_platform = scene_platform[0].instantiate() as StaticBody2D
			last_platform_is_trap = false
		new_platform.position = Vector2(randf_range(20, 340), platform_y_pos)
		platform_container.call_deferred("add_child", new_platform)

func delete_broken_platform(platform) -> void:
	platform.queue_free()
	if not to_boss_fight:
		level_generator(1)
	
func _on_platform_eraser_body_entered(body) -> void:
	if body.is_in_group("platform") or body.is_in_group("boss_platform"):
		body.queue_free()
		if not to_boss_fight:
			level_generator(1)
	elif body.is_in_group("player"):
		print('death prompt and its ui')
		get_tree().reload_current_scene()

func score_update() -> void:
	score = camera_init_y_pos - camera.position.y
	score_label.text = str(int(score + player.additional_score))

func _on_area_2d_body_entered(body) -> void:
	if body.is_in_group("boss_platform") and to_boss_fight:
		boss_fighting = true
		await get_tree().create_timer(2).timeout
		spawn_boss()
		
func toggle_boss_platfom(b: bool) -> void:
	boss_platform.visible = b
	for child in boss_platform.get_children():
		if child is CollisionShape2D:
			child.disabled = not b
		
func toggle_side_platform():
	if left_platform != null:
		right_platform = scene_platform[4].instantiate() as StaticBody2D
		right_platform.position = Vector2(randf_range(195, 345), platform_y_pos - randf_range(10, 50))
		platform_container.call_deferred("add_child", right_platform)
		await get_tree().create_timer(0.9).timeout
		left_platform.queue_free()
	else:
		left_platform = scene_platform[4].instantiate() as StaticBody2D
		left_platform.position = Vector2(randf_range(15, 165), platform_y_pos - randf_range(10, 50))
		platform_container.call_deferred("add_child", left_platform)
		await get_tree().create_timer(0.9).timeout
		right_platform.queue_free()
	await get_tree().create_timer(1.5).timeout
		
func boss_platform_attack() -> void:
	left_platform = scene_platform[4].instantiate() as StaticBody2D
	left_platform.position = Vector2(randf_range(15, 165), platform_y_pos - randf_range(10, 50))
	platform_container.call_deferred("add_child", left_platform)
	
	await get_tree().create_timer(2).timeout
	toggle_boss_platfom(false)
	await get_tree().create_timer(1).timeout
	
	for i in range(11):
		await toggle_side_platform()
	
	toggle_boss_platfom(true)
	await get_tree().create_timer(0.3).timeout
	right_platform.queue_free()
	boss_instance.attack_completed.emit()
		
func spawn_boss() -> void:
	boss_instance = boss.instantiate()
	boss_position = Vector2(180, platform_y_pos - 588)
	boss_instance.global_position = boss_position
	boss_instance.apply_shake.connect(apply_shake)
	boss_instance.platform_attack.connect(boss_platform_attack)
	#boss_instance.additional_score.connect(add_score_from_enemy_hit)
	boss_instance.end_phase.connect(end_boss_phase)
	camera.add_child(boss_instance)
	await boss_instance.start(player)
	end_boss_phase()

func end_boss_phase() -> void:
	target_score_for_boss += score_needed_between_boss
	print("ending boss phase...")
	player.disable_movement()
	
	#Regenerate Platform
	for i in range(8):
		level_generator(1)
		#Play sound
		await get_tree().create_timer(0.3).timeout
	level_generator(12)
	
	player.enable_movement()
	await get_tree().create_timer(0.1).timeout
	boss_fighting = false
	to_boss_fight = false

#func add_score_from_enemy_hit(num: int) -> void:
	#additional_score += num

func setup_shake() -> void:
	rand.randomize()
	# Randomize the generated noise
	noise.seed = rand.randi()
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	# Frequency affects how quickly the noise changes values
	noise.frequency = 0.5
	
func apply_shake() -> void:
	shake_strength = RANDOM_SHAKE_STRENGTH
	
func process_camera_shake(delta: float) -> void:
	# Fade out the intensity over time
	shake_strength = lerp(shake_strength, 0.0, SHAKE_DECAY_RATE * delta)
	
	var shake_offset: Vector2
	shake_offset = get_noise_offset(delta, NOISE_SHAKE_SPEED, shake_strength)
	
	# Shake by adjusting camera.offset so we can move the camera around the level via it's position
	camera.offset = shake_offset

func get_noise_offset(delta: float, speed: float, strength: float) -> Vector2:
	noise_i += delta * speed
	# Set the x values of each call to 'get_noise_2d' to a different value
	# so that our x and y vectors will be reading from unrelated areas of noise
	return Vector2(
		noise.get_noise_2d(1, noise_i) * strength,
		noise.get_noise_2d(100, noise_i) * strength
	)

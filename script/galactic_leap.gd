extends Node2D

@onready var game = $"."
@onready var player = $Player
@onready var camera = $Camera2D
@onready var score_label = $Camera2D/Score
@onready var camera_init_y_pos = $Camera2D.position.y
@onready var platform_container = $platform_container
@onready var platform_y_pos = $platform_container/platform.position.y
@onready var boss_bgm = $AudioStreamPlayer2D
@onready var death_ui = $Camera2D/CanvasLayer/death_ui
@onready var playing_bgm = $AudioStreamPlayer2D2
@export var scene_platform:Array[PackedScene]

#Noise Shake taken from: https://github.com/theshaggydev/the-shaggy-dev-projects

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

var screen_size

#Background
var background = preload("res://scene/background/background.tscn")
var background_y_pos = -570

#Enemies n Boss
var boss = preload("res://scene/boss.tscn")
var static_enemy = preload("res://scene/static_enemy.tscn")
var moving_enemy = preload("res://scene/moving_enemy.tscn")
var current_level = 0
var boss_instance
var boss_platform
var left_platform
var right_platform

#Enemies control but dumb af
var choices = [5, 5, 2, 2, 5, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2]

var score = 0
var game_over = false

var target_score_for_boss = 1
var score_needed_between_boss = 10000
var addition_score_needed = 2000
var boss_position

var last_platform_is_trap = false
var player_is_above = true
var to_boss_fight = false
var boss_fighting = false

func _ready() -> void:
	get_tree().paused = false
	screen_size = get_viewport_rect().size
	level_generator(20, false)
	playing_bgm.play()

func _physics_process(_delta: float) -> void:
	if player == null:
		return
	if not game_over:
		score_update()
	if not boss_fighting:
		if player.position.y < camera.position.y:
			camera.position.y = player.position.y
			player_is_above = true
		else:
			player_is_above = false
	
func _process(delta: float) -> void:
	if player == null:
		return
	process_camera_shake(delta)

	if not player_is_above and not boss_fighting:
		camera.position.y -= 80 * delta
		
	if score >= target_score_for_boss and not to_boss_fight:
		to_boss_fight = true
		generate_platform_on_boss()

func generate_platform_on_boss() -> void:
	platform_y_pos -= 90
	boss_platform = scene_platform[3].instantiate() as StaticBody2D
	boss_platform.position = Vector2(155, platform_y_pos)
	platform_container.call_deferred("add_child", boss_platform)

func level_generator(amount: int, has_enemy: bool) -> void:
	for i in amount:
		var random_num = randi_range(0, 5)
		platform_y_pos -= randf_range(60, 80)
		var new_platform
		
		if not last_platform_is_trap and random_num < 2 and has_enemy:
			var random_choice
			if current_level > 1:
				random_choice = choices[randi_range(0, len(choices) - 1)]
			else:
				random_choice = 2
			new_platform = scene_platform[random_choice].instantiate() as StaticBody2D
			last_platform_is_trap = true
			new_platform.connect("delete_broken_platform", delete_broken_platform)
		else:
			if random_num == 3 and abs(score - target_score_for_boss) > 3000 and current_level <= 10:
				new_platform = scene_platform[1].instantiate() as StaticBody2D
			else:
				new_platform = scene_platform[0].instantiate() as StaticBody2D
			last_platform_is_trap = false
		new_platform.position = Vector2(randf_range(10, 300), platform_y_pos)
		platform_container.call_deferred("add_child", new_platform)

func delete_broken_platform(platform) -> void:
	platform.queue_free()
	if not to_boss_fight:
		level_generator(1, true)
	
func _on_platform_eraser_body_entered(body) -> void:
	if body.is_in_group("platform"):
		body.queue_free()
		if not to_boss_fight:
			level_generator(1, true)
	elif body.is_in_group("player"):
		body.player_death()

func score_update() -> void:
	score = camera_init_y_pos - camera.position.y
	score_label.text = str(int(score + player.additional_score))

func _on_area_2d_body_entered(body) -> void:
	if body.is_in_group("boss_platform") and to_boss_fight:
		boss_fighting = true
		playing_bgm.stop()
		boss_bgm.play()
		await get_tree().create_timer(2).timeout
		spawn_boss()
		handle_enemy()

func handle_enemy() -> void:
	for i in range(min(current_level, 6)):
		await get_tree().create_timer(randf_range(2, 3)).timeout
		randomize()
		spawn_moving_enemy()
		spawn_static_enemy()

func toggle_boss_platfom(b: bool) -> void:
	if b:
		boss_platform.appear()
	else:
		boss_platform.disappear()
		
func toggle_side_platform():
	if left_platform != null:
		right_platform = scene_platform[4].instantiate() as StaticBody2D
		right_platform.position = Vector2(randf_range(165, 300), platform_y_pos - randf_range(40, 90))
		platform_container.call_deferred("add_child", right_platform)
		await get_tree().create_timer(0.9).timeout
		left_platform.destroy()
		left_platform = null
	else:
		left_platform = scene_platform[4].instantiate() as StaticBody2D
		left_platform.position = Vector2(randf_range(10, 145), platform_y_pos - randf_range(40, 90))
		platform_container.call_deferred("add_child", left_platform)
		await get_tree().create_timer(0.9).timeout
		right_platform.destroy()
		right_platform = null
	await get_tree().create_timer(1.5).timeout
		
func boss_platform_attack() -> void:
	left_platform = scene_platform[4].instantiate() as StaticBody2D
	left_platform.position = Vector2(randf_range(10, 145), platform_y_pos - randf_range(40, 90))
	platform_container.call_deferred("add_child", left_platform)
	
	await get_tree().create_timer(2).timeout
	toggle_boss_platfom(false)
	await get_tree().create_timer(3).timeout
	
	for i in range(11):
		await toggle_side_platform()
	
	toggle_boss_platfom(true)
	await get_tree().create_timer(0.3).timeout
	right_platform.destroy()
	boss_instance.attack_completed.emit()
		
func spawn_boss() -> void:
	boss_instance = boss.instantiate()
	boss_position = Vector2(155, platform_y_pos - 520)
	boss_instance.modulate = Color(1, 1, 1, 0)
	boss_instance.platform_y_pos = platform_y_pos
	boss_instance.global_position = boss_position
	boss_instance.apply_shake.connect(apply_shake)
	boss_instance.platform_attack.connect(boss_platform_attack)
	boss_instance.end_phase.connect(end_boss_phase)
	camera.add_child(boss_instance)
	boss_instance.start(player, current_level)

func _get_random_x_pos_outside() -> float:
	var random_x_pos
	if player.position.x < screen_size.x/2:
		random_x_pos  = randf_range(-20, -10)
	else:
		random_x_pos = randf_range(320, 330)
	return random_x_pos

func _get_random_x_pos() -> float:
	var random_x_pos  = [randf_range(10, 120), randf_range(180, 300)]
	return random_x_pos[randi_range(0, 1)]
	
func spawn_static_enemy() -> void:
	var enemy_instance = static_enemy.instantiate()
	var random_x_pos = _get_random_x_pos()
	var enemy_position = Vector2(random_x_pos, platform_y_pos - 350)
	enemy_instance.global_position = enemy_position
	camera.add_child(enemy_instance)

func spawn_moving_enemy() -> void:
	var enemy_instance = moving_enemy.instantiate()
	var random_x_pos = _get_random_x_pos_outside()
	var list_of_y_pos = [190, 220, 250, 280, 310]
	var enemy_position = Vector2(random_x_pos, platform_y_pos - list_of_y_pos[randi_range(0, len(list_of_y_pos) - 1)])
	enemy_instance.global_position = enemy_position
	camera.add_child(enemy_instance)

func end_boss_phase() -> void:
	current_level += 1
	if current_level <= 10:
		choices.pop_back()
	target_score_for_boss += score_needed_between_boss
	score_needed_between_boss += addition_score_needed
	print("ending boss phase...")
	player.disable_movement()
	
	#Regenerate Platform
	for i in range(8):
		level_generator(1, false)
		#Play sound
		await get_tree().create_timer(0.3).timeout
	level_generator(12, true)
	
	player.enable_movement()
	await get_tree().create_timer(0.1).timeout
	boss_fighting = false
	playing_bgm.play()
	boss_bgm.stop()
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

func _on_platform_eraser_area_exited(area):
	if area.is_in_group("background"):
		area.queue_free()
		var background_instance = background.instantiate()
		background_y_pos -= screen_size.y
		background_instance.global_position = Vector2(screen_size.x/2, background_y_pos)
		game.add_child(background_instance)
		game.move_child(background_instance, 0)

func _on_platform_eraser_body_exited(body):
	if body.is_in_group("enemy"):
		body.queue_free()
	elif body.is_in_group("boss_platform"):
		body.queue_free()
		if not to_boss_fight:
			level_generator(1, true)

func _on_player_death_signal():
	game_over = true
	await get_tree().create_timer(1).timeout
	get_tree().paused = true
	death_ui.visible = true
	death_ui.set_score(score_label.text)

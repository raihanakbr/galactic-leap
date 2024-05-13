extends Node2D

@onready var player = $Player
@onready var camera = $Camera2D
@onready var score_label = $Camera2D/Score
@onready var camera_init_y_pos = $Camera2D.position.y
@onready var platform_container = $platform_container
@onready var platform_y_pos = $platform_container/platform.position.y
@export var scene_platform:Array[PackedScene]

var score = 0
var last_platform_is_trap = false
var player_is_above = true

func level_generator(amount):
	for i in amount:
		var random_num = randi_range(0, 5)
		platform_y_pos -= randf_range(60, 80)
		var new_platform
		
		if not last_platform_is_trap and random_num < 2:
			new_platform = scene_platform[2].instantiate() as StaticBody2D
			last_platform_is_trap = true
			new_platform.connect("delete_broken_platform", delete_broken_platform)
		else:
			if random_num == 3:
				new_platform = scene_platform[1].instantiate() as StaticBody2D
			else:
				new_platform = scene_platform[0].instantiate() as StaticBody2D
			last_platform_is_trap = false
		new_platform.position = Vector2(randf_range(20, 340), platform_y_pos)
		platform_container.call_deferred("add_child", new_platform)

func delete_broken_platform(platform):
	platform.queue_free()
	level_generator(1)

func _ready():
	level_generator(20)

func _physics_process(_delta):
	score_update()
	if player.position.y < camera.position.y:
		camera.position.y = player.position.y
		player_is_above = true
	else:
		player_is_above = false
	
func _process(_delta):
	if not player_is_above:
		camera.position.y -= 1
	
func _on_platform_eraser_body_entered(body):
	body.queue_free()
	level_generator(1)

func score_update():
	score = camera_init_y_pos - camera.position.y
	score_label.text = str(int(score))

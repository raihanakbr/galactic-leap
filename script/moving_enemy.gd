extends StaticBody2D

var speed = 40
var health = 2
var dir
var screen
var target_x_point
var is_idle = false

@onready var idle_timer: Timer = $IdleTimer
@onready var sprite = $Sprite2D

func _ready():
	set_as_top_level(true)
	screen = get_viewport_rect().size
	update_target_point()

func _physics_process(delta):
	movement(delta)

func update_target_point():
	if position.x < screen.x / 2:
		dir = Vector2(1, 0)
		target_x_point = randf_range(200, 300)
		sprite.frame = 1
	else:
		dir = Vector2(-1, 0)
		target_x_point = randf_range(10, 110)
		sprite.frame = 0

func flip():
	dir *= -1
	update_target_point()

func movement(delta):
	if is_idle:
		return

	var velocity = dir * speed
	position += velocity * delta
	
	if dir == Vector2(1, 0) and position.x > target_x_point:
		start_idle()
	elif dir == Vector2(-1, 0) and position.x < target_x_point:
		start_idle()

func start_idle():
	is_idle = true
	speed = 0
	idle_timer.wait_time = 2;
	idle_timer.start()

func _on_idle_timer_timeout():
	is_idle = false
	speed = 100
	flip()

func take_damage():
	health -= 1
	if health <= 0:
		queue_free()

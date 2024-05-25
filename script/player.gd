extends CharacterBody2D

@onready var weapon = $weapon
@onready var dash = $dash

#Dashing
@export var dash_ghost: PackedScene
@export var dash_speed: float = 2000.0
@export var dash_length = 0.002
var can_dash: bool = true
var dash_direction: Vector2
var facing_direction: int = -1

var gravity = 10
var jump_force = 600
var speed = 300.0
var playerVelocity = Vector2.ZERO
var can_move = true

func _ready() -> void:
	pass

func movement(delta):
	playerVelocity.y += gravity
	var collision = move_and_collide(playerVelocity * delta)
	if collision and (collision.get_collider().is_in_group("platform") or collision.get_collider().is_in_group("boss_platform")):
		playerVelocity.y = -jump_force * collision.get_collider().jump_power
		if collision.get_collider().has_method("response"):
			collision.get_collider().response()
	
	var dir = 0
	if Input.is_action_pressed("ui_right"):
		facing_direction = 1
		dir += 1
		$AnimatedSprite2D.flip_h = true
	elif Input.is_action_pressed("ui_left"):
		facing_direction = -1
		dir -= 1
		$AnimatedSprite2D.flip_h = false
		
	if dash.is_dashing():
		playerVelocity.x = lerp(playerVelocity.x, facing_direction * dash_speed, 0.8)
	elif dir != 0:
		playerVelocity.x = lerp(playerVelocity.x, dir * speed, 0.8)
	else:
		playerVelocity.x = lerp(playerVelocity.x, 0.0, 0.2)
		
	if position.x < 0:
		var adjusted_pos = get_viewport_rect().size.x
		position.x = adjusted_pos
		weapon.position.x = adjusted_pos
	elif position.x > get_viewport_rect().size.x:
		position.x = 0
		weapon.position.x = 0

func _physics_process(delta: float) -> void:
	if not can_move:
		return
	handle_dash(delta)
	movement(delta)
	
func handle_dash(_delta: float) -> void:
	if Input.is_action_just_pressed("dash") and dash.can_dash:
		dash.start_dash(dash_length)
	
func disable_movement():
	can_move = false

func enable_movement():
	can_move = true

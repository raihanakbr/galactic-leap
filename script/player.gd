extends CharacterBody2D

signal death_signal

@onready var weapon = $weapon
@onready var dash = $dash
@onready var sprite = $Sprite2D
@onready var jump_sound = $AudioStreamPlayer2D
@onready var broke_platform_sound = $AudioStreamPlayer2D2
@onready var death = $AudioStreamPlayer2D3
@onready var collision = $CollisionShape2D

#Dashing
@export var dash_ghost: PackedScene
@export var dash_speed: float = 2000.0
@export var dash_length = 0.01
var can_dash: bool = true
var dash_direction: Vector2
var facing_direction: int = -1
var additional_score = 0

var gravity = 10
var jump_force = 600
var speed = 300.0
var playerVelocity = Vector2.ZERO
var can_move = true
var boss_fighting = false
var on_ground

func _ready() -> void:
	enable_movement()
	weapon.add_score.connect(add_score)
	pass

func _collision_check(delta) -> void:
	var collision = move_and_collide(playerVelocity * delta)
	if collision and collision.get_collider().is_in_group("platform"):
		playerVelocity.y = -jump_force * collision.get_collider().jump_power
		if collision.get_collider().has_method("response"):
			collision.get_collider().response()
			broke_platform_sound.play()
		else:
			jump_sound.play()
	elif collision and collision.get_collider().is_in_group("boss_platform"):
		jump_sound.play()
		playerVelocity.y = -jump_force * collision.get_collider().jump_power
		boss_fighting = true
		on_ground = true
	elif collision and collision.get_collider().is_in_group("enemy"):
		player_death()

func _jump():
	if boss_fighting and on_ground:
		playerVelocity.y = -jump_force
		on_ground = false

func movement(delta):
	playerVelocity.y += gravity
	_collision_check(delta)
	
	var dir = 0
	var mouse_pos = get_global_mouse_position()
	
	if mouse_pos.x > global_position.x: # right
		if mouse_pos.y < global_position.y:
			sprite.frame = 5
		else:
			sprite.frame = 3
	elif mouse_pos.x < global_position.x: #left
		if mouse_pos.y < global_position.y:
			sprite.frame = 2
		else:
			sprite.frame = 0
	
	if Input.is_action_pressed("ui_right"):
		facing_direction = 1
		dir += 1
		#sprite.frame = 3
		#$AnimatedSprite2D.flip_h = true
	elif Input.is_action_pressed("ui_left"):
		facing_direction = -1
		dir -= 1
		#sprite.frame = 0
		#$AnimatedSprite2D.flip_h = false
		
		
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
	weapon.can_move = false

func enable_movement():
	can_move = true
	weapon.can_move = true
	
func add_score(score):
	additional_score += score
	
func player_death() -> void:
	death.play()
	disable_movement()
	collision.disabled = true
	weapon.visible = false
	sprite.visible = false
	death_signal.emit()
	#get_tree().reload_current_scene()

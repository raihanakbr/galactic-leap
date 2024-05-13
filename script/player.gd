extends CharacterBody2D

var gravity = 10
var jump_force = 600
var speed = 300.0
var playerVelocity = Vector2.ZERO

func movement(delta):
	playerVelocity.y += gravity
	var collision = move_and_collide(playerVelocity * delta)
	if collision:
		playerVelocity.y = -jump_force * collision.get_collider().jump_power
		if collision.get_collider().has_method("response"):
			collision.get_collider().response()
	
	var dir = 0
	if Input.is_action_pressed("ui_right"):
		dir += 1
		$AnimatedSprite2D.flip_h = true
	elif Input.is_action_pressed("ui_left"):
		dir -= 1
		$AnimatedSprite2D.flip_h = false
		
	if dir != 0:
		playerVelocity.x = lerp(playerVelocity.x, dir * speed, 0.8)
	else:
		playerVelocity.x = lerp(playerVelocity.x, 0.0, 0.2)
		
	if position.x < 0:
		position.x = get_viewport_rect().size.x
	elif position.x > get_viewport_rect().size.x:
		position.x = 0

func _physics_process(delta):
	movement(delta)

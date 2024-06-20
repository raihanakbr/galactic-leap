extends StaticBody2D

@onready var collision = $CollisionShape2D
@onready var anim = $AnimatedSprite2D
@export var jump_power = 0

signal delete_broken_platform(platform)

func response():
	anim.play()
	collision.disabled = true

func _on_animated_sprite_2d_animation_looped():
	delete_broken_platform.emit(self)

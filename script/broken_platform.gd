extends StaticBody2D

@onready var collision = $CollisionShape2D
@export var jump_power = 0

signal delete_broken_platform(platform)

func response():
	delete_broken_platform.emit(self)

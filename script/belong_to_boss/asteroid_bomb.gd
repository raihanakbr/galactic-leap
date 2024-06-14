extends Area2D

@export var speed = 800

var health = 2

func _ready():
	set_as_top_level(true)

func _process(delta):
	position += (Vector2.RIGHT * speed).rotated(rotation) * delta
	speed = max(0, speed - 40)

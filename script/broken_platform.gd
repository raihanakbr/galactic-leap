extends StaticBody2D

@export var jump_power = 0

signal delete_broken_platform(platform)

func response():
	emit_signal("delete_broken_platform", self)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

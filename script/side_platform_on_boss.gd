extends StaticBody2D

@export var jump_power = 0.6
@onready var anim = $AnimationPlayer

func _ready() -> void:
	anim.play("show")

func destroy() -> void:
	anim.play("destroy")
	
func delete() -> void:
	queue_free()

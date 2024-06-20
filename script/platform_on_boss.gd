extends StaticBody2D

@export var jump_power = 0.6
@onready var anim_player = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func disappear() -> void:
	anim_player.play("hide")

func appear() -> void:
	anim_player.play("show")

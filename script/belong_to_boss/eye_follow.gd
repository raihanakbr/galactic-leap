extends Sprite2D

@onready var boss = $".."
@onready var anim = $"../AnimatedSprite2D"
var player
var init_pos

# Called when the node enters the scene tree for the first time.
func _ready():
	init_pos = global_position - boss.global_position
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if player != null:
		# y from init_y + (0 to 14)
		# x from -31 to 31
		var x_pos = (player.position.x - 155) * 31 / 155
		var y_pos = (player.position.y - boss.position.y - 220) * 14 / 296 + init_pos.y
		position = Vector2(x_pos, y_pos)
		anim.position = position + Vector2(0, -64)

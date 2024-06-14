extends StaticBody2D

var projectile = preload("res://scene/belong_to_boss/asteroid.tscn")

var player
var can_attack = true
var player_detected = false
var player_position
var health = 3

# Called when the node enters the scene tree for the first time.
func _ready():
	set_as_top_level(true)
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if can_attack and player_detected:
		can_attack = false
		await get_tree().create_timer(0.5).timeout
		attack()
		await get_tree().create_timer(1.5).timeout
		can_attack = true

func attack():
	var projectile_instance = projectile.instantiate()
	projectile_instance.global_position = global_position
	projectile_instance.look_at(player.position)
	get_parent().add_child(projectile_instance)

func take_damage():
	health -= 1
	if health <= 0:
		queue_free()

func _on_area_2d_body_entered(body):
	if body.is_in_group("player"):
		player_detected = true
		player = body
		print(body)

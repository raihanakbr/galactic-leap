extends Node2D

const dash_delay = 0.5

@onready var timer = $dash_timer
var can_dash = true

func start_dash(dur):
	timer.wait_time = dur
	timer.start()

func is_dashing():
	return not timer.is_stopped()

func end_dash() -> void:
	can_dash = false
	await get_tree().create_timer(dash_delay).timeout
	can_dash = true
	
func _on_dash_timer_timeout():
	end_dash()

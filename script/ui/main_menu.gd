extends Control

@onready var play_button = $Button
@onready var game_scene = preload("res://scene/galactic_leap.tscn")

func _ready():
	get_tree().reload_current_scene()

func _on_button_button_down():
	get_tree().change_scene_to_packed(game_scene)

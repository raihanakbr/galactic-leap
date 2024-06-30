extends Control

@onready var play_button = $Button
@onready var token_scene = preload("res://scene/ui/token.tscn")

func _ready():
	#get_tree().reload_current_scene()
	pass

func _on_button_button_down():
	get_tree().change_scene_to_packed(token_scene)
	pass

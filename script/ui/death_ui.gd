extends Control

@onready var main_menu = preload("res://scene/ui/main_menu.tscn")
@onready var game_scene = preload("res://scene/galactic_leap.tscn")
@onready var score_label = $Label

# Called when the node enters the scene tree for the first time.
func _ready():
	visible = false
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func set_score(score):
	score_label.text = "SCORE:" + score

func _on_button_button_down():
	get_tree().change_scene_to_packed(game_scene)


func _on_button_2_button_down():
	get_tree().change_scene_to_packed(main_menu)

extends Control

@onready var submit_token = preload("res://scene/ui/token.tscn")
@onready var score_label = $Label
@onready var http_request = $HTTPRequest

# Called when the node enters the scene tree for the first time.
func _ready():
	visible = false
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func set_score(score):
	score_label.text = "SCORE:" + score
	var payload = {
		"userPlaygroundId": Global.userPlaygroundId,
		"attemptId": Global.attemptId,
		"score": Global.score
	}
	var err = _http_request.request(sha512, headers, HTTPClient.METHOD_POST, JSON.stringify(payload))

func _on_button_button_down():
	get_tree().change_scene_to_packed(submit_token)

func _on_button_2_button_down():
	pass

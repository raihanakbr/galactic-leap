extends Control

@onready var _http_request = $HTTPRequest
@onready var _text_message = $Label
@onready var _code_input = $NinePatchRect/NinePatchRect2/LineEdit
@onready var _submit_button = $NinePatchRect/NinePatchRect/Button

func _ready():
	GlobalGameCodeVerifier.RequestFailed.connect(
		func(error_message: String) -> void:
			_text_message.text = "Failed to send request: %s" % error_message
			_submit_button.disabled = false
	)
	
	GlobalGameCodeVerifier.GameCodeSucceed.connect(
		func(response_messages: String) -> void:
			_text_message.text = response_messages
			get_tree().change_scene_to_file("res://scene/galactic_leap.tscn")
	)
	
	GlobalGameCodeVerifier.GameCodeFailed.connect(
		func(error_message: String) -> void:
			_text_message.text = error_message
			_submit_button.disabled = false
	)

func _on_button_button_down():
	_submit_button.disabled = true
	_text_message.text = "Connecting to server..."
	GlobalGameCodeVerifier.verify_game_code(_code_input.text)

func _on_http_request_request_completed(result, response_code, headers, body):
	pass

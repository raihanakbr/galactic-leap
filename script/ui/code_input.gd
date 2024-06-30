extends Node

@onready var status_label: Label = $Control/Label
@onready var line_edit: LineEdit = $Control/NinePatchRect/NinePatchRect2/LineEdit
@onready var submit_button: Button = $Control/NinePatchRect/NinePatchRect/Button

func _ready() -> void:
	submit_button.button_down.connect(_button_pressed)
	
	GlobalGameCodeVerifier.RequestFailed.connect(
		func(error_message: String) -> void:
			status_label.text = "Failed to send request: %s" % error_message
			submit_button.disabled = false
	)
	
	GlobalGameCodeVerifier.GameCodeSucceed.connect(
		func(response_messages: String) -> void:
			status_label.text = response_messages
			print("astagoy")
	)
	
	GlobalGameCodeVerifier.GameCodeFailed.connect(
		func(error_message: String) -> void:
			status_label.text = error_message
			submit_button.disabled = false
	)

func _button_pressed():
	print("yeye")
	pass

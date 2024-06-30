extends Node

const URL := "https://www.devglan.com/online-tools/hmac-sha256-online"

var _http_request: HTTPRequest
var _result := ""


func _ready():
	_http_request = HTTPRequest.new()
	add_child(_http_request)
	_http_request.request_completed.connect(_on_request_completed)


func sha512_base64(payload: Dictionary) -> String:
	var headers := [
		"Content-Type: application/json",
	]
	
	if _http_request.request(URL, headers, HTTPClient.METHOD_POST, JSON.stringify(payload)) == OK:
		await _http_request.request_completed
		return _result
	
	# TODO: HTTPRequest error handling
	return ""


func _on_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	var result_body = body.get_string_from_utf8()
	
	if response_code == 200:
		var json = JSON.new()
		var parse_result = json.parse_string(result_body)
		_result = parse_result.outputString
	else:
		# TODO: Server response error handling
		_result = ""

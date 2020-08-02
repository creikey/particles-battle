extends Control

class_name GameConfig

signal host
signal join(lobby_code, username)

export (NodePath) var error_label_path
export (NodePath) var username_line_edit_path
export (NodePath) var lobby_name_line_edit_path

onready var error_label: Label = get_node(error_label_path)
onready var username_line_edit: LineEdit  = get_node(username_line_edit_path)
onready var lobby_name_line_edit: LineEdit = get_node(lobby_name_line_edit_path)

enum ERROR_TYPE {
	username_validation,
	lobby_code_validation
}

var _cur_error_type: int = 0
var _currently_shown_error_type: int = 0

func _on_JoinButton_pressed():
	if not _validate_username(username_line_edit.text):
		return
	if not _validate_lobby_code(lobby_name_line_edit.text):
		return
	if _is_showing_error():
		return
	emit_signal("join", lobby_name_line_edit.text, username_line_edit.text)

func _on_HostButton_pressed():
	if not _validate_username(username_line_edit.text):
		return
	if _is_showing_error():
		return
	emit_signal("host")

func _validate_lobby_code(code: String) -> bool:
	_cur_error_type = ERROR_TYPE.lobby_code_validation
	
	if code.length() != WebsocketsRTCServer.JOIN_CODE_LENGTH:
		_error(str("Lobby join codes are ", WebsocketsRTCServer.JOIN_CODE_LENGTH, " characters long"))
		return false

	if _currently_shown_error_type == _cur_error_type:
		_hide_error()
	
	return true

func _validate_username(username: String) -> bool:
	_cur_error_type = ERROR_TYPE.username_validation
	if username.length() < 3:
		_error("username needs to be at least 3 characters long")
		return false
	if username.length() > 20:
		_error("username must be less than 21 characters long")
		return false
	var validation_regex := RegEx.new()
# warning-ignore:return_value_discarded
	validation_regex.compile("[A-Za-z0-9]*")
	assert(_is_regex_match(validation_regex, "creikey") == true)
	assert(_is_regex_match(validation_regex, "AfeL143fds") == true)
	assert(_is_regex_match(validation_regex, "f34$#") == false)
	
	if not _is_regex_match(validation_regex, username):
		_error("username must use only letters and numbers, no spaces")
		return false
	
	if _currently_shown_error_type == _cur_error_type:
		_hide_error()
	
	return true

static func _is_regex_match(regex: RegEx, string: String) -> bool:
	var regex_match: RegExMatch = regex.search(string)
	return (regex_match != null and regex_match.get_string() == string)

func _error(reason: String):
	_currently_shown_error_type = _cur_error_type
	error_label.text = reason
	error_label.visible = true

func _is_showing_error() -> bool:
	return error_label.visible

func _hide_error():
	error_label.visible = false

func _on_Username_text_changed(new_text):
# warning-ignore:return_value_discarded
	_validate_username(new_text)


func _on_LobbyName_text_changed(new_text):
# warning-ignore:return_value_discarded
	_validate_lobby_code(new_text)

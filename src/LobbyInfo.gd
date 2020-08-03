extends VBoxContainer

class_name LobbyInfo

var code: String = "" setget set_code
var connected_user: String = "" setget set_connected_user

func set_code(new_code):
	code = new_code
	$HostingLabel.text = str("Hosting lobby at: ", code)

func set_connected_user(new_connected_user):
	connected_user = new_connected_user
	if connected_user == "":
		$StatusLabel.text = str("User disconnected! Waiting for a connection...")
	else:
		$StatusLabel.text = str("User connected! Preparing to fight with ", connected_user, "...")

func _on_CopyToClipboardButton_pressed():
	OS.clipboard = code

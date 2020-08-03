extends Control

export (NodePath) var networking_tabs_path
export (NodePath) var game_config_path
export (NodePath) var connecting_label_path
export (NodePath) var lobby_info_path

onready var networking_tabs: TabContainer = get_node(networking_tabs_path)
onready var game_config: GameConfig = get_node(game_config_path)
onready var connecting_label: Label = get_node(connecting_label_path)
onready var lobby_info: LobbyInfo = get_node(lobby_info_path)
onready var client: MultiplayerRTCClient = $Client
onready var error_dialog: AcceptDialog = $ErrorDialog

var _connected_peer: int = 0

func _ready():
	# has to be in editor on desktop to host signaling server
	$DebugButtons.visible = OS.get_name() != "HTML5" and not OS.has_feature("standalone")
	
	# see if should start serving
	var args: Array = OS.get_cmdline_args()
	if args.size() > 0 and args[0].begins_with("--serve"):
		_switch_to_server()
	
	# start connecting
#	_connect()

func _connect(lobby: String = ""):
	networking_tabs.current_tab = 1
	var target_url: String = Globals.get_url()
	print("Connecting to '", target_url, "'")
	client.start(target_url, lobby)

func _switch_to_server() -> void:
# warning-ignore:return_value_discarded
	get_tree().change_scene("res://WebRTC/Server/WebsocketsRTCServer.tscn")


func _on_HostSignalingButton_pressed():
	_switch_to_server()


func _on_GameConfig_join(lobby_code: String, username: String):
	client.username = username # TODO make the same as _on_GameConfig_host
	_connect(lobby_code)

func _on_GameConfig_host():
	client.username = game_config.username_line_edit.text
	_connect()


func _on_Client_lobby_joined(lobby):
	networking_tabs.current_tab = 2
	lobby_info.code = lobby
	print("Joined lobby ", lobby)
	# TODO show lobby to invite others


func _error(text: String):
	error_dialog.dialog_text = text
	error_dialog.popup_centered()
	networking_tabs.current_tab = 0


func _on_Client_disconnected():
	_error("Disconnected")


func _on_Client_peer_connected(id, username: String):
	_connected_peer = id
	lobby_info.connected_user = username


func _on_Client_peer_disconnected(id):
	if id == _connected_peer:
		lobby_info.connected_user = ""

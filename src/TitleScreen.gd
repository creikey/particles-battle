extends Control

export (NodePath) var game_config_path
export (NodePath) var connecting_label_path

onready var game_config: GameConfig = get_node(game_config_path)
onready var connecting_label: Label = get_node(connecting_label_path)
onready var client: MultiplayerRTCClient = $Client

func _ready():
	# has to be in editor on desktop to host signaling server
	$DebugButtons.visible = OS.get_name() != "HTML5" and not OS.has_feature("standalone")
	
	# see if should start serving
	var args: Array = OS.get_cmdline_args()
	if args.size() > 0 and args[0] == "--serve":
		_switch_to_server()
	
	# start connecting
	_connect()

func _connect(lobby: String = "", ip_override: String = ""):
	var target_ip: String = WebsocketsRTCServer.PRODUCTION_SERVER_ADDRESS
	var target_port: int = 443
	if not OS.has_feature("standalone"):
		target_ip = "127.0.0.1"
		target_port = WebsocketsRTCServer.DEBUG_PORT
	if ip_override != "":
		target_ip = ip_override
	var target_url: String = str(target_ip, ":", target_port)
	print("Connecting to ", target_url)
	client.start(target_url, lobby)

func _switch_to_server() -> void:
	get_tree().change_scene("res://WebRTC/Server/WebsocketsRTCServer.tscn")


func _on_HostSignalingButton_pressed():
	_switch_to_server()


func _on_Client_websocket_connected():
	connecting_label.visible = false
	game_config.visible = true


func _on_GameConfig_join(lobby_code: String):
	_connect(lobby_code)

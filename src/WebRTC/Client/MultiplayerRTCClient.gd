extends WebsocketsRTCClient

class_name MultiplayerRTCClient

var rtc_mp: WebRTCMultiplayer = WebRTCMultiplayer.new()
var sealed = false

func _init():
	var _err: int = connect("connected", self, "connected")
	_err = connect("disconnected", self, "disconnected")

	_err = connect("offer_received", self, "offer_received")
	_err = connect("answer_received", self, "answer_received")
	_err = connect("candidate_received", self, "candidate_received")

	_err = connect("lobby_joined", self, "lobby_joined")
	_err = connect("lobby_sealed", self, "lobby_sealed")
	_err = connect("peer_connected", self, "peer_connected")
	_err = connect("peer_disconnected", self, "peer_disconnected")


func start(url, lobby = ""):
	stop()
	sealed = false
	self.lobby = lobby
	connect_to_url(url)


func stop():
	rtc_mp.close()
	close()

func _get_text_file(n: String) -> String:
	var file := File.new()
# warning-ignore:return_value_discarded
	file.open(str("res://", n), File.READ)
	var to_return: String = file.get_as_text()
	file.close()
	return to_return.dedent().split("\n")[0]

func _create_peer(id):
	var peer: WebRTCPeerConnection = WebRTCPeerConnection.new()
	var username: String = _get_text_file("turn_username.txt")
	var credential: String = _get_text_file("turn_password.txt")
#	print("Username: `", username , "`, Password: `", credentials, "`")
	var _err: int = peer.initialize({
		"iceServers": [ 
			{ "urls": ["stun:stun.l.google.com:19302"] },
			{
				"urls": ["turn:particlesturnserver.ddns.net:3478"],
				"username": username,
				"credential": credential,
			}
		]
	})
	_err = peer.connect("session_description_created", self, "_offer_created", [id])
	_err = peer.connect("ice_candidate_created", self, "_new_ice_candidate", [id])
	_err = rtc_mp.add_peer(peer, id)
	if id > rtc_mp.get_unique_id():
		_err = peer.create_offer()
	return peer


func _new_ice_candidate(mid_name, index_name, sdp_name, id):
# warning-ignore:return_value_discarded
	send_candidate(id, mid_name, index_name, sdp_name)


func _offer_created(type, data, id):
	if not rtc_mp.has_peer(id):
		return
	print("created", type)
	rtc_mp.get_peer(id).connection.set_local_description(type, data)
	if type == "offer":
# warning-ignore:return_value_discarded
		send_offer(id, data)
	else:
# warning-ignore:return_value_discarded
		send_answer(id, data)


func connected(id):
	print("Connected %d" % id)
# warning-ignore:return_value_discarded
	rtc_mp.initialize(id, true)


func lobby_joined(lobby):
	self.lobby = lobby


func lobby_sealed():
	sealed = true


func disconnected():
	print("Disconnected: %d: %s" % [code, reason])
	if not sealed:
		stop() # Unexpected disconnect


func peer_connected(id: int, username: String):
	print("Peer connected %d, %s" % [id, username])
	_create_peer(id)


func peer_disconnected(id):
	if rtc_mp.has_peer(id): rtc_mp.remove_peer(id)


func offer_received(id, offer):
	print("Got offer: %d" % id)
	if rtc_mp.has_peer(id):
		rtc_mp.get_peer(id).connection.set_remote_description("offer", offer)


func answer_received(id, answer):
	print("Got answer: %d" % id)
	if rtc_mp.has_peer(id):
		rtc_mp.get_peer(id).connection.set_remote_description("answer", answer)


func candidate_received(id, mid, index, sdp):
	if rtc_mp.has_peer(id):
		rtc_mp.get_peer(id).connection.add_ice_candidate(mid, index, sdp)

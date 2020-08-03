extends Node

class_name Globals

# will cause everything to be over SSL and go to a-hoy.club, production server address
#const PRODUCTION_SERVER: bool = false
const PRODUCTION_SERVER: bool = true

const PRODUCTION_PORT: int  = 443
const PRODUCTION_ADDRESS: String = "a-hoy.club"

const DEBUG_PORT: int = 4876
const DEBUG_ADDRESS: String = "localhost"

static func needs_ssl() -> bool:
	return PRODUCTION_SERVER

static func get_address() -> String:
	if PRODUCTION_SERVER:
		return PRODUCTION_ADDRESS
	else:
		return DEBUG_ADDRESS

static func get_port() -> int:
	if PRODUCTION_SERVER:
		return PRODUCTION_PORT
	else:
		return DEBUG_PORT

static func get_url() -> String:
	var prefix: String = "ws://"
	var suffix: String = str(":", get_port())
	if PRODUCTION_SERVER:
		prefix = "wss://"
#		suffix = ""
	return str(prefix, get_address(), suffix)

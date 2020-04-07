extends Node

const LAYER_WORLD: int = (1 << 0)
const LAYER_FENCE: int = (1 << 1)
const LAYER_ENTITIES: int = (1 << 2)
const LAYER_PROJECTILES: int = (1 << 3)
const LAYER_TRIGGERS: int = (1 << 4)

# Categories of event that can be masked
const EVENT_BIT_GAME_STATE: int = (1 << 0)
const EVENT_BIT_ENTITY_SPAWN: int = (1 << 1)
const EVENT_BIT_ENTITY_TRIGGER: int = (1 << 2)
const EVENT_BIT_UI: int = (1 << 3)

# Types of event
const EVENT_LEVEL_LOADING: String = "level_loading" # The level is changing - cleanup
# Level has loaded, gameplay begins shortly
# the intention of prestart is to allow further load steps to broadcast that they are working
# and to prevent gameplay from starting until they are ready
const EVENT_LEVEL_PRESTART: String = "level_prestart"
const EVENT_LEVEL_START: String = "level_start" # gameplay has started
const EVENT_LEVEL_COMPLETE: String = "level_complete" # a game end condition has been met

const EVENT_PLAYER_SPAWN: String = "player_spawned"
const EVENT_PLAYER_DIED: String = "player_died"

const EVENT_PLAYER_GAINED_POWER: String = "player_gained_power"

const EVENT_MOB_SPAWN: String = "mob_spawned"
const EVENT_MOB_DIED: String = "mob_died"

const EVENT_ENTITY_TRIGGER: String = "ent_trigger"

const CMD_START_GAME: String = "start"
const CMD_EXIT_APP: String = "exit"
const CMD_GOTO_TITLE: String = "gototitle"
const CMD_GOTO_DEVMAP: String = "gotodev"
const CMD_SYSTEM_INFO: String = "sys"
const CMD_TRIGGER_ENTS: String = "trigger"
const CMD_SPAWN: String = "spawn"

const TEAM_PLAYER: int =  0
const TEAM_MOBS: int = 1

const DEG2RAD = 0.017453292519
const RAD2DEG = 57.29577951308

var debugSpawnPosition: Vector3 = Vector3()

func get_window_to_screen_ratio():
	var real: Vector2 = OS.get_real_window_size()
	var scr: Vector2 = OS.get_screen_size()
	var result: Vector2 = Vector2(real.x / scr.x, real.y / scr.y)
	return result

func dot_product(x0: float, y0: float, x1: float, y1: float):
	return x0 * x1 + y0 * y1

func is_point_left_of_line2D(lineOrigin: Vector2, lineSize: Vector2, p: Vector2):
	var vx: float = lineOrigin.x - p.x
	var vy: float = lineOrigin.y - p.y
	var lineNormalX: float = lineSize.y
	var lineNormalY: float = -lineSize.x
	var dp: float = dot_product(vx, vy, lineNormalX, lineNormalY)
	return (dp > 0)

func calc_pitch_degrees3D(v3:Vector3):
	var radians = atan2(v3.y, v3.x)
	return radians * RAD2DEG

func calc_yaw_degrees3D(v3:Vector3):
	var radians = atan2(v3.z, v3.x)
	return radians * RAD2DEG

func calc_euler_degrees(v: Vector3):
	# yaw
	var yawRadians = atan2(-v.x, -v.z)
	# pitch
	var flat = Vector3(v.x, 0, v.z)
	var flatMagnitude = flat.length()
	var pitchRadians = atan2(v.y, flatMagnitude)
	var result = Vector3(pitchRadians * RAD2DEG, yawRadians * RAD2DEG, 0)
	return result

func strNullOrEmpty(txt: String):
	if txt == null:
		return true
	elif txt.length() == 0:
		return true
	return false

# safely search and retrieve an interactor from a node
func extract_interactor(obj):
	if !obj.has_method("get_interactor"):
		return null
	return obj.get_interactor()
	
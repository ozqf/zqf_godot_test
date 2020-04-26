extends Node

# Must be kept in sync with physics layers setup in project
# (look under [layer_names] in project.godot)
const LAYER_WORLD: int = (1 << 0)
const LAYER_FENCE: int = (1 << 1)
const LAYER_ENTITIES: int = (1 << 2)
const LAYER_PROJECTILES: int = (1 << 3)
const LAYER_TRIGGERS: int = (1 << 4)
const LAYER_ITEMS: int = (1 << 5)
const LAYER_PLAYER: int = (1 << 6)

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
const CMD_LIST_ENTS: String = "ents"
const CMD_SPAWN: String = "spawn"

const TEAM_PLAYER: int =  0
const TEAM_MOBS: int = 1

const DEG2RAD = 0.017453292519
const RAD2DEG = 57.29577951308

var debugSpawnPosition: Vector3 = Vector3()
var debugSpawnType: String = "mob"

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

func calc_euler_degrees(v: Vector3):
	# yaw
	var yawRadians = atan2(-v.x, -v.z)
	# pitch
	var flat = Vector3(v.x, 0, v.z)
	var flatMagnitude = flat.length()
	var pitchRadians = atan2(v.y, flatMagnitude)
	var result = Vector3(pitchRadians * RAD2DEG, yawRadians * RAD2DEG, 0)
	return result

# > Take a basis and cast a line forward from it to an endpoint
# > Offset the endpoint right and up based on spread values
# > return the direction toward this new endpoint
# TODO: This function uses arbitrary units for spread as the distanced used is not scaled properly
func calc_forward_spread_from_basis(_origin: Vector3, _m3x3: Basis, _spreadHori: float, _spreadVert: float):
	var forward: Vector3 = _m3x3.z
	var up: Vector3 = _m3x3.y
	var right: Vector3 = _m3x3.x
	# TODO: Magic value 8192 means spread values are not proper units like degrees
	var end: Vector3 = VectorMA(_origin, 8192, -forward)
	end = VectorMA(end, _spreadHori, right)
	end = VectorMA(end, _spreadVert, up)
	return (end - _origin).normalized()

func VectorMA(start: Vector3, scale: float, dir:Vector3):
	var dest: Vector3 = Vector3()
	dest.x = start.x + dir.x * scale
	dest.y = start.y + dir.y * scale
	dest.z = start.z + dir.z * scale
	return dest

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


##########################################
# TODO: Cleanup Defunct maths junk
##########################################

# func calc_flat_plane_radians(dir: Vector3):
# 	# source - C++ example
# 	# implementation here has swapped Y and Z axes
# 	# double yaw = Math.Atan2(ds.X, ds.Y);
# 	# double pitch = Math.Atan2(ds.Z, Math.Sqrt((ds.X * ds.X) + (ds.Y * ds.Y)));
# 	var result: Vector3 = Vector3()
# 	# yaw
# 	result.y = atan2(dir.x, dir.z)
# 	result.x = atan2(dir.y, sqrt((dir.x * dir.x) + (dir.z * dir.z)))
# 	return result

# func calc_flat_plane_radians_alt1(dir: Vector3):
# 	var flatMag: float = dir.length()
# 	var result:Vector3 = Vector3()
# 	# x == pitch, y == yaw
# 	result.y = atan2(dir.x, dir.z)
# 	result.x = atan2(dir.y, flatMag)
# 	return result

# func calc_euler_to_forward3D_1(pitchDegrees: float, yawDegrees: float):
# 	var pitch = pitchDegrees * DEG2RAD
# 	var yaw = yawDegrees * DEG2RAD
# 	var matrix: Basis = Basis.IDENTITY
# 	# inverted pitch for some reason...?
# 	# order sensitive. apply pitch then yaw!
# 	matrix = matrix.rotated(Vector3(1, 0, 0), -pitch)
# 	matrix = matrix.rotated(Vector3(0, 1, 0), yaw)
# 	return matrix.z

# func calc_pitch_degrees3D(v3:Vector3):
# 	var radians = atan2(v3.y, v3.z)
# 	return radians * RAD2DEG

# func calc_yaw_degrees3D(v3:Vector3):
# 	var radians = atan2(v3.x, v3.z)
# 	return radians * RAD2DEG

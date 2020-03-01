extends Node

const EVENT_BIT_GAME_STATE: int = (1 << 0)
const EVENT_BIT_ENTITY_SPAWN: int = (1 << 1)

const EVENT_LEVEL_START: String = "level_start"
const EVENT_LEVEL_LOADING: String = "level_loading"
const EVENT_LEVEL_COMPLETE: String = "level_complete"

const CMD_START_GAME: String = "start"
const CMD_EXIT_APP: String = "exit"
const CMD_GOTO_TITLE: String = "gototitle"

const DEG2RAD = 0.017453292519
const RAD2DEG = 57.29577951308

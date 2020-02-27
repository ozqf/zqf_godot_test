# Godot Engine notes

These are notes regarding doing basic boilerplate stuff with the Godot Engine.

## GDScript snippets

### Instance a Prefab in code
```
# Import scene type
var my_prefab_type = preload("res://prefabs/my_prefab.tscn")

# create an instance
func foo:
    # 'new' instance
    var obj = my_prefab_type.instance()
    # object must be placed in the node tree
    add_child(obj)
```

### Array
```
# declare
var _arr = []
# push
_arr.push_back(obj)
# pop
var i:int = _arr.find(obj)
_arr_.remove(i)
# reset
_arr.clear()
# length
_arr.size()
# count - number of times an entry appears in the array
_arr.count()
```

### Node Tree traversal/usage

Get Root of current:
```instance()```

## GDScript - Language elements

### Absent features

These are common language features not present in gdscript (no comment on whether this is a good or bad thing):
* ++ or --
* switch
* private (everything is public)
* static variables. const instead of var is supported though eg
```
const DEG2RAD = 0.017453292519
const RAD2DEG = 57.2958
```
functions CAN be static however. Presumably all data must be passed in via arguments however?

### Useful extra keywords

* $ can be used as shorthand for get_node
eg ```get_node("NodePath").foo``` becomes ```$NodePath.foo```
* PI, TAU, INF (infinity), NAN
* Base types null, bool, int, float, String. Take that javascript. A proper int type.
* Looks like Bitwise ops fully supported

### ToString
str(variable)
eg
```var txt = "Count is: " + str(count)```

### Globals

Globals are handled via an Auto load singleton.
Once a global script is setup in Project Settings -> Autoload you can use its name to access it
eg if you create a 'globals' auto load script, you can do this:
```var degrees = radians * common.RAG2DEG```

Seems like a bit of a faff but here goes:
http://docs.godotengine.org/en/latest/getting_started/step_by_step/singletons_autoload.html

* Project menu -> Project Settings
* Autoload tab
* Add script (click singleton)

## Application Node layouts

root
	- globals (autoload singleton)
		- children of globals scene
		- main menu etc
		- Screens that shared by game scenes, eg score screen.
	- game scene (the primary scene to load as set in project settings)
		- world
		- ents
		- ...etc


## GUI

Types
Button
    CheckBox
    CheckButton
    ColorPickerButton
    MenuButton
    OptionButton
    ToolButton
LinkButton
TextureButton

HScrollBar
VScrollBar
ScrollContainer

## Collision Groups

* World - vs ents and projectiles
* Fence - vs ents
* Ents - vs ents, vs world, vs projectiles, vs fences
* projectiles - vs ents, vs world

## Links

### Editor

Cheatsheet of shortcuts
https://github.com/godotengine/godot/issues/4875

### Scripting

#### General
https://docs.godotengine.org/en/3.2/getting_started/scripting/gdscript/gdscript_basics.html

#### API Classes
https://docs.godotengine.org/en/3.2/classes/index.html

#### Error Codes
http://docs.godotengine.org/en/3.2/classes/class_@globalscope.html#enum-globalscope-error

#### Input
https://docs.godotengine.org/en/3.2/tutorials/inputs/mouse_and_input_coordinates.html

### Collision detection
http://docs.godotengine.org/en/latest/tutorials/physics/physics_introduction.html
http://docs.godotengine.org/en/latest/classes/class_kinematiccollision2d.html

### Tutorials
More comprehensive "first game"
https://godot.readthedocs.io/en/latest/getting_started/step_by_step/your_first_game.html
FPS - pretty feature complete as far as fundamentals are concerned
https://docs.godotengine.org/en/3.2/tutorials/3d/fps_tutorial/index.html
Ultra basics - Flappy bird clone
https://generalistprogrammer.com/tag/godot-3-2d-tutorial/


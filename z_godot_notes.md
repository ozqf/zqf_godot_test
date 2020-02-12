# Godot Engine notes

These are notes regarding doing basic boilerplate stuff with the Godot Engine.

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

### ToString
str(variable)
eg
```var txt = "Count is: " + str(count)```


### Globals

Globals are handled via an Auto load singleton.
Once a global script is setup in Project Settings -> Autoload you can use its name to access it
eg if you create a 'globals' auto load script, you can do this:
```var degrees = radians * globals.RAD2DEG```

Seems like a bit of a faff but here goes:
http://docs.godotengine.org/en/latest/getting_started/step_by_step/singletons_autoload.html

* Project menu -> Project Settings
* Autoload tab
* Add script (click singleton)

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

## Links

### Scripting

Error Codes
http://docs.godotengine.org/en/3.2/classes/class_@globalscope.html#enum-globalscope-error

https://docs.godotengine.org/en/3.2/getting_started/scripting/gdscript/gdscript_basics.html
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


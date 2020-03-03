## AI

### State Machine

#### Sensors

#### Brief

Stack based AI state machine.
New states are pushed onto the stack. When they finished they are popped and the previous state resumes.

In most cases this would be a little more complex. Eg being stunned whilst attacking:
* Pop attack state from stack (doing logic that might be required to stop attack sequence)
* Push a stun state with the desired wait time

#### States

##### State types

Inactive - not present in game.
Idle
	description - awaiting activation via line of sight, sound or other triggers
	exits
		detects a target
Move
	description - toward some position, usually an attack target
	exits
		time, reaching goal (within some range limit)
Attack
	description - fire some form of attack sequence
	requirements - a target
	exits
		end of attack sequence
		loss of line of sight (if attack has no time limit)
		AI state change (most likely stun or death)
MoveAndAttack
	Runs Move and Attack logic at the same time....?
stun
	description - temporary state of idle due to damage.
	exits: TimeOut.
Spawn
	description - entity is entering the world and is not yet active
	exits - sequence completes.
Die
	description - entity is dying
	exits - mob is resurrected/recycled
FixedJump
	description - follows some pre-scripted movement until it finishes.

##### State Interfaces

States:
```
void Init(StateMachine machine); // pass in external access
void OnActivateState(); // Setup
void OnDeactivateState(); // Clean up
void OnTick();
void OnTock();
```

StateMachine
```
PushState(int stateType)
PopState()
```
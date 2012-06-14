## Event (should be immutable)

* states
    * init
    * received
    * dispatched
    * consumed

## Response

nil: not handled
non nil: transition target state name

## State

* name
* machine
* react(ev) :Response
* entry(ev) :Response
* exit(ev) :Response

## StateMachine

* currentState
* statesTree
* statesDict
* react(ev) :Response
* _transit(state)

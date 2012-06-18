local exports = {}

local string = require('string')
local table = require('table')
local histm = require('../histm.lua')
local State = histm.State
local StateMachine = histm.StateMachine

exports['substate1'] = function (test)
  local On = State:extend()
  On.name = 'On'

  function On:initialize(children)
    State.initialize(self, children)
    self.keyMap = {
      ['off'] = 'Final'
    }
  end

  function On:react(keyName)
    return self.keyMap[keyName]
  end

  function On:exit()
    table.insert(self.machine.log, 'On:exit')
  end

  local Operand1 = State:extend()
  Operand1.name = 'Operand1'

  function Operand1:initialize(children)
    State.initialize(self, children)
    self.keyMap = {
      ['+'] = 'OpEntered',
      ['-'] = 'OpEntered',
      ['*'] = 'OpEntered',
      ['/'] = 'OpEntered'
    }
  end

  function Operand1:react(keyName)
    return self.keyMap[keyName]
  end

  local OpEntered = State:extend()
  OpEntered.name = 'OpEntered'

  function OpEntered:initialize(children)
    State.initialize(self, children)
    self.keyMap = {
      ['0'] = 'Operand2',
      ['1'] = 'Operand2',
      ['2'] = 'Operand2',
      ['3'] = 'Operand2',
      ['4'] = 'Operand2',
      ['5'] = 'Operand2',
      ['6'] = 'Operand2',
      ['7'] = 'Operand2',
      ['8'] = 'Operand2',
      ['9'] = 'Operand2',
      ['.'] = 'Operand2'
    }
  end

  function OpEntered:react(keyName)
    return self.keyMap[keyName]
  end

  function OpEntered:exit()
    table.insert(self.machine.log, 'OpEntered:exit')
  end

  local Operand2 = State:extend()
  Operand2.name = 'Operand2'

  function Operand2:initialize(children)
    State.initialize(self, children)
    self.keyMap = {
      ['-'] = 'Result'
    }
  end

  function Operand2:react(keyName)
    return self.keyMap[keyName]
  end

  local Result = State:extend()
  Result.name = 'Result'

  function Result:initialize(children)
    State.initialize(self, children)
    self.keyMap = {
      ['0'] = 'Operand1',
      ['1'] = 'Operand1',
      ['2'] = 'Operand1',
      ['3'] = 'Operand1',
      ['4'] = 'Operand1',
      ['5'] = 'Operand1',
      ['6'] = 'Operand1',
      ['7'] = 'Operand1',
      ['8'] = 'Operand1',
      ['9'] = 'Operand1',
      ['.'] = 'Operand1',
      ['+'] = 'OpEntered',
      ['-'] = 'OpEntered',
      ['*'] = 'OpEntered',
      ['/'] = 'OpEntered'
    }
  end

  function Result:react(keyName)
    return self.keyMap[keyName]
  end

  local Final = State:extend()
  Final.name = 'Final'

  function Final:entry()
    table.insert(self.machine.log, 'Final:entry')
  end

  function Result:initialize(children)
    State.initialize(self, children)
  end

  local Calculator = StateMachine:extend()

  function Calculator:initialize()
    local operand1 = Operand1:new()
    local opEntered = OpEntered:new()
    local operand2 = Operand2:new()
    local result = Result:new()
    local on = On:new{operand1, opEntered, operand2, result}
    local final = Final:new()
    self:addTopStates{on, final}
    self.state = operand1
    self.log = {}
  end

  local calculator = Calculator:new()
  calculator:react('+')
  test.equal(calculator.state.name, 'OpEntered')
  calculator:react('off')
  test.equal(calculator.state.name, 'Final')
  test.equal('OpEntered:exit,On:exit,Final:entry',
    table.concat(calculator.log, ','))
  test.done()
end

return exports

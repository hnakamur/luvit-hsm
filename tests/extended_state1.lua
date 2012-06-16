local exports = {}

local string = require('string')
local hsm = require('../hsm.lua')
local State = hsm.State
local StateMachine = hsm.StateMachine

exports['extended_state1'] = function (test)
  local Default = State:extend()
  Default.name = 'Default'

  function Default:react(keyName)
    if keyName == 'CAPS_LOCK' then
      return 'CapsLocked'
    else
      self.machine:pressKey(string.lower(keyName))
      return self.machine.keyCount > 0 and 'Default' or 'Final'
    end
  end

  local CapsLocked = State:extend()
  CapsLocked.name = 'CapsLocked'

  function CapsLocked:react(keyName)
    if keyName == 'CAPS_LOCK' then
      return 'Default'
    else
      self.machine:pressKey(string.upper(keyName))
      return self.machine.keyCount > 0 and 'CapsLocked' or 'Final'
    end
  end

  local Final = State:extend()
  Final.name = 'Final'

  local FragileKeyboard = StateMachine:extend()

  function FragileKeyboard:initialize()
    local default = Default:new()
    local capsLocked = CapsLocked:new()
    local final = Final:new()
    self:addStates{default, capsLocked, final}
    self.state = default
    self.keyCount = 5;
  end

  function FragileKeyboard:pressKey(keyName)
    self.output = keyName
    self.keyCount = self.keyCount - 1
  end

  local keyboard = FragileKeyboard:new()
  keyboard:react('a')
  test.equal(keyboard.output, 'a')
  keyboard:react('b')
  test.equal(keyboard.output, 'b')
  keyboard:react('CAPS_LOCK')
  keyboard:react('c')
  test.equal(keyboard.output, 'C')
  keyboard:react('d')
  test.equal(keyboard.output, 'D')
  keyboard:react('CAPS_LOCK')
  keyboard:react('e')
  test.equal(keyboard.output, 'e')
  test.equal('Final', keyboard.state.name)
  test.done()
end

return exports

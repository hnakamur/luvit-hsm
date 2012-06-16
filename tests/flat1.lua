local exports = {}

local string = require('string')
local histm = require('../histm.lua')
local State = histm.State
local StateMachine = histm.StateMachine

exports['flat1'] = function (test)
  local Default = State:extend()
  Default.name = 'Default'

  function Default:react(keyName)
    if keyName == 'CAPS_LOCK' then
      return 'CapsLocked'
    else
      self:emit('LowerCaseScanCode', keyName)
      return 'Default'
    end
  end

  local CapsLocked = State:extend()
  CapsLocked.name = 'CapsLocked'

  function CapsLocked:react(keyName)
    if keyName == 'CAPS_LOCK' then
      return 'Default'
    else
      self:emit('UpperCaseScanCode', keyName)
      return 'CapsLocked'
    end
  end

  local Keyboard = StateMachine:extend()

  function Keyboard:initialize()
    local default = Default:new()
    local capsLocked = CapsLocked:new()
    self:addStates{default, capsLocked}
    self.state = default
    default:on('LowerCaseScanCode', function(keyName)
      self.output = string.lower(keyName)
    end)
    capsLocked:on('UpperCaseScanCode', function(keyName)
      self.output = string.upper(keyName)
    end)
  end

  local keyboard = Keyboard:new()
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
  test.done()
end

return exports

local exports = {}

local string = require('string')
local hsm = require('../hsm.lua')
local StateMachine = hsm.StateMachine

exports['flat1'] = function (test)
  local Keyboard = StateMachine:extend()

  function Keyboard:initialize()
    self:setStates{
      Default = {
        react = function(keyName)
          if keyName == 'CAPS_LOCK' then
            return 'CapsLocked'
          else
            self:handleLowerCaseScanCode(keyName)
            return 'Default'
          end
        end
      },
      CapsLocked = {
        react = function(keyName)
          if keyName == 'CAPS_LOCK' then
            return 'Default'
          else
            self:handleUpperCaseScanCode(keyName)
            return 'CapsLocked'
          end
        end
      }
    }
    self.state = self.statesMap.Default
  end

  function Keyboard:handleLowerCaseScanCode(keyName)
    self.output = string.lower(keyName)
  end

  function Keyboard:handleUpperCaseScanCode(keyName)
    self.output = string.upper(keyName)
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

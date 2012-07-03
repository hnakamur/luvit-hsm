local exports = {}

local string = require('string')
local hsm = require('../hsm.lua')
local StateMachine = hsm.StateMachine

exports['extended_state1'] = function (test)
  local FragileKeyboard = StateMachine:extend()

  function FragileKeyboard:initialize()
    self:setStates{
      Default = {
        react = function(keyName)
          if keyName == 'CAPS_LOCK' then
            return 'CapsLocked'
          else
            self:handleLowerCaseScanCode(keyName)
            return self.keyCount > 0 and 'Default' or 'Final'
          end
        end
      },
      CapsLocked = {
        react = function(keyName)
          if keyName == 'CAPS_LOCK' then
            return 'Default'
          else
            self:handleUpperCaseScanCode(keyName)
            return self.keyCount > 0 and 'CapsLocked' or 'Final'
          end
        end
      },
      Final = {
      }
    }
    self.stateName = 'Default'
    self.keyCount = 5
  end

  function FragileKeyboard:handleLowerCaseScanCode(keyName)
    self.output = string.lower(keyName)
    self.keyCount = self.keyCount - 1
  end

  function FragileKeyboard:handleUpperCaseScanCode(keyName)
    self.output = string.upper(keyName)
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
  test.ok(keyboard.stateName, 'Final')
  test.done()
end

return exports

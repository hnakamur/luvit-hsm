local exports = {}

local string = require('string')
local table = require('table')
local histm = require('../histm.lua')
local StateMachine = histm.StateMachine

exports['substate1'] = function (test)
  local Calculator = StateMachine:extend()

  function Calculator:initialize()
    self:setStates{
      On = {
        react = (function()
          local keyMap = {
            off = 'Final'
          }
          return function(keyName)
            return keyMap[keyName]
          end
        end)(),
        exit = function()
          table.insert(self.log, 'On:exit')
        end,
        substates = {
          Operand1 = {
            react = (function()
              local keyMap = {
                ['+'] = 'OpEntered',
                ['-'] = 'OpEntered',
                ['*'] = 'OpEntered',
                ['/'] = 'OpEntered'
              }
              return function(keyName)
                return keyMap[keyName]
              end
            end)(),
          },
          OpEntered = {
            react = (function()
              local keyMap = {
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
              return function(keyName)
                return keyMap[keyName]
              end
            end)(),
            exit = function()
              table.insert(self.log, 'OpEntered:exit')
            end
          },
          Operand2 = {
            react = (function()
              local keyMap = {
                ['-'] = 'Result'
              }
              return function(keyName)
                return keyMap[keyName]
              end
            end)(),
          },
          Result = {
            react = (function()
              local keyMap = {
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
              return function(keyName)
                return keyMap[keyName]
              end
            end)(),
          }
        }
      },
      Final = {
        entry = function()
          table.insert(self.log, 'Final:entry')
        end
      }
    }
    self.state = self.statesMap.Operand1
    self.log = {}
  end

  local calculator = Calculator:new()
  calculator:react('+')
  test.equal(calculator.state.name, 'OpEntered')
  calculator.log = {}
  calculator:react('off')
  test.equal(calculator.state.name, 'Final')
  test.equal('OpEntered:exit,On:exit,Final:entry',
    table.concat(calculator.log, ','))
  test.done()
end

return exports

local exports = {}

local string = require('string')
local hsm = require('../hsm.lua')
local HierarchicalStateMachine = hsm.HierarchicalStateMachine

exports['isAncestorOf'] = function (test)
  local TestMachine = HierarchicalStateMachine:extend()
  
  function TestMachine:initialize()
    self:setStates{
      a = {
        substates = {
          b = {
            substates = {
              c = {
              },
              d = {
                substates = {
                  e = {
                  }
                }
              }
            }
          }
        }
      }
    }
  end

  local machine = TestMachine:new()
  test.equal(machine:_isAncestorOf('e', nil), false)
  test.equal(machine:_isAncestorOf('e', 'e'), true)
  test.equal(machine:_isAncestorOf('d', 'e'), true)
  test.equal(machine:_isAncestorOf('a', 'e'), true)
  test.equal(machine:_isAncestorOf('e', 'c'), false)
  test.done()
end

exports['getLCA'] = function (test)
  local TestMachine = HierarchicalStateMachine:extend()
  
  function TestMachine:initialize()
    self:setStates{
      a = {
        substates = {
          b = {
            substates = {
              c = {
              },
              d = {
                substates = {
                  e = {
                  }
                }
              }
            }
          }
        }
      }
    }
  end

  local machine = TestMachine:new()
  test.equal(machine:_getLCA('e', nil), nil)
  test.equal(machine:_getLCA('e', 'd'), 'd')
  test.equal(machine:_getLCA('d', 'e'), 'd')
  test.equal(machine:_getLCA('e', 'c'), 'b')
  test.done()
end

return exports

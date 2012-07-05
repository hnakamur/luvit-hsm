local exports = {}

local table = require('table')
local hsm = require('../hsm.lua')
local HierarchicalStateMachine = hsm.HierarchicalStateMachine

exports['localTransition'] = function (test)
  local TestMachine = HierarchicalStateMachine:extend()
  
  function TestMachine:initialize()
    self:setStates{
      S1 = {
        entry = TestMachine._entryS1,
        react = TestMachine._reactS1,
        exit = TestMachine._exitS1,
        substates = {
          S2 = {
            entry = TestMachine._entryS2,
            react = TestMachine._reactS2,
            exit = TestMachine._exitS2
          }
        }
      }
    }
    self.state = self.states.S1
  end

  function TestMachine:_entryS1()
    self:addLog('s1_entry')
  end
  function TestMachine:_reactS1(event)
    self:addLog('s1_react')
    return 'S2'
  end
  function TestMachine:_exitS1()
    self:addLog('s1_exit')
  end

  function TestMachine:_entryS2()
    self:addLog('s2_entry')
  end
  function TestMachine:_reactS2(event)
    self:addLog('s2_react')
    return 'S1'
  end
  function TestMachine:_exitS2()
    self:addLog('s2_exit')
  end

  function TestMachine:addLog(log)
    table.insert(self.log, log)
  end

  local machine = TestMachine:new()
  machine.log = {}
  machine:react()
  test.equal('s1_react,s2_entry', table.concat(machine.log, ','))

  machine.log = {}
  machine:react()
  test.equal('s2_react,s2_exit', table.concat(machine.log, ','))

  machine.log = {}
  machine:react()
  test.equal('s1_react,s2_entry', table.concat(machine.log, ','))

  test.done()
end

return exports

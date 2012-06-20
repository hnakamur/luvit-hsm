local exports = {}

local table = require('table')
local hsm = require('../hsm.lua')
local StateMachine = hsm.StateMachine

exports['local_transition'] = function (test)
  local machine
  machine = StateMachine:new{
    initStateName = 's1',
    states = {
      s1 = {
        entry = function()
          machine:addLog('s1_entry')
        end,
        react = function(event)
          machine:addLog('s1_react')
          return 's2'
        end,
        exit = function()
          machine:addLog('s1_exit')
        end,
        substates = {
          s2 = {
            entry = function()
              machine:addLog('s2_entry')
            end,
            react = function(event)
              machine:addLog('s2_react')
              return 's1'
            end,
            exit = function()
              machine:addLog('s2_exit')
            end
          }
        }
      }
    }
  }

  function machine:addLog(log)
    table.insert(self.log, log)
  end

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

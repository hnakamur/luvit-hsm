local exports = {}

local table = require('table')
local hsm = require('../hsm.lua')
local StateMachine = hsm.StateMachine

exports['initial'] = function (test)
  local door
  door = StateMachine:new{
    initStateName = 'initial',
    states = {
      initial = {
        react = function(event)
          if event == 'create' then
            door:addLog('initial')
            return 'open'
          else
            return nil
          end
        end
      },
      open = {
        entry = function()
          door:addLog('open_entry')
        end,
        react = function(event)
          if event == 'close' then
            door:addLog('open_react')
            return 'closed'
          else
            return nil
          end
        end,
        exit = function()
          door:addLog('open_exit')
        end
      },
      closed = {
        entry = function()
          door:addLog('closed_entry')
        end,
        react = function(event)
          if event == 'open' then
            door:addLog('closed_react')
            return 'open'
          else
            return nil
          end
        end,
        exit = function()
          door:addLog('closed_exit')
        end
      }
    }
  }

  function door:addLog(log)
    table.insert(self.log, log)
  end

  door.log = {}
  door:react('create')
  test.equal('initial,open_entry', table.concat(door.log, ','))

  door.log = {}
  door:react('close')
  test.equal('open_react,open_exit,closed_entry', table.concat(door.log, ','))

  test.done()
end

return exports

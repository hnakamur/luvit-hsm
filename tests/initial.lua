local exports = {}

local table = require('table')
local hsm = require('../hsm.lua')
local StateMachine = hsm.StateMachine

exports['initial'] = function (test)
  local Door = StateMachine:extend()

  function Door:initialize()
    self:setStates{
      initial = {
        react = function(event)
          if event == 'create' then
            self:addLog('initial')
            return 'open'
          else
            return nil
          end
        end
      },
      open = {
        entry = function()
          self:addLog('open_entry')
        end,
        react = function(event)
          if event == 'close' then
            self:addLog('open_react')
            return 'closed'
          else
            return nil
          end
        end,
        exit = function()
          self:addLog('open_exit')
        end
      },
      closed = {
        entry = function()
          self:addLog('closed_entry')
        end,
        react = function(event)
          if event == 'open' then
            self:addLog('closed_react')
            return 'open'
          else
            return nil
          end
        end,
        exit = function()
          self:addLog('closed_exit')
        end
      }
    }
    self.state = self.states['initial']
  end

  function Door:addLog(log)
    table.insert(self.log, log)
  end

  local door = Door:new()
  door.log = {}
  door:react('create')
  test.equal('initial,open_entry', table.concat(door.log, ','))

  door.log = {}
  door:react('close')
  test.equal('open_react,open_exit,closed_entry', table.concat(door.log, ','))

  test.done()
end

return exports

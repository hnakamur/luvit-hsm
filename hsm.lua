local core = require("core")
local Object = core.Object
local Emitter = core.Emitter

local hsm = {}

--local Event = Object:extend()
--hsm.Event = Event
--
--function Event:initialize(type, parameters)
--  self.type = type
--  self.parameters = parameters
--end


local State = Emitter:extend()
hsm.State = State

--function State:addChild(child)
--  self.children = self.children or {}
--  self.children[#self.children + 1] = child
--  child.parent = self
--end

local StateMachine = Object:extend()
hsm.StateMachine = StateMachine

function StateMachine:initialize()
  self.statesMap = {}
end

function StateMachine:addStates(states)
  self.statesMap = self.statesMap or {}
  for _, state in pairs(states) do
    self.statesMap[state.name] = state
    state.machine = self
  end
end

function StateMachine:react(...)
  local newStateName = self.state:react(...)
  if newStateName then
    if newStateName ~= self.state.name then
      self:_transit(newStateName)
    end
  else
    -- TODO: propagate event to parent machine
  end
end

function StateMachine:_transit(newStateName)
  self.state = self.statesMap[newStateName]
end

return hsm

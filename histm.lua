local core = require("core")
local table = require("table")
local Object = core.Object
local Emitter = core.Emitter

local histm = {}

--local Event = Object:extend()
--histm.Event = Event
--
--function Event:initialize(type, parameters)
--  self.type = type
--  self.parameters = parameters
--end


local State = Emitter:extend()
histm.State = State

function State:initialize(children)
  if children ~= nil then
    self.substates = {}
    for _, child in pairs(children) do
      child.superstate = self
      self.substates[#self.substates + 1] = child
    end
  end
end

function State:isAncestorOf(state)
  local s = state
  while s ~= nil do
    if self == s then return true end
    s = s.superstate
  end
  return false
end

function State:getLCA(state)
  local s = state
  while s ~= nil do
    if s:isAncestorOf(self) then
      return s
    end
    s = s.superstate
  end
  return nil
end

local StateMachine = Object:extend()
histm.StateMachine = StateMachine

local function _addStateToMap(self, state)
  self.statesMap[state.name] = state
  state.machine = self
  if state.substates then
    for i, child in ipairs(state.substates) do
      _addStateToMap(self, child)
    end
  end
end

function StateMachine:addTopStates(states)
  self.statesMap = {}
  for i, state in ipairs(states) do
    _addStateToMap(self, state)
  end
end

function StateMachine:react(...)
  local state = self.state
  while state ~= nil do
    local newStateName = state:react(...)
    if newStateName ~= nil then -- consumed
      if newStateName ~= state.name then
        self:_transit(newStateName)
      end
      break
    else
      state = state.superstate
    end
  end
end

function StateMachine:_transit(newStateName)
  if self.state and self.state.exit then self.state:exit() end
  self.state = self.statesMap[newStateName]
  if self.state and self.state.entry then self.state:entry() end
end

return histm

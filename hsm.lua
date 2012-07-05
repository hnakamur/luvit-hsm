local core = require("core")
local Emitter = core.Emitter

local hsm = {}

local StateMachine = Emitter:extend()

function StateMachine:setStates(states)
  self.states = states
end

function StateMachine:react(...)
  local targetState = self.state.react(self, ...)
  if targetState and targetState ~= self.state then
    self:_transit(targetState)
  end
end

function StateMachine:_transit(targetState)
  self:_runExitActions(self.state)
  self:_runEntryActions(targetState)
  self.state = targetState
end

function StateMachine:_runExitActions(sourceState)
  if sourceState.exit then
    sourceState.exit(self)
  end
end

function StateMachine:_runEntryActions(targetState)
  if targetState.entry then
    targetState.entry(self)
  end
end


local function clone(table)
  local ret = {}
  for k, v in pairs(table) do
    ret[k] = v
  end
  return ret
end

local function indexOf(table, elem)
  for i = 1, #table do
    if table[i] == elem then
      return i
    end
  end
  return nil
end

local HierarchicalStateMachine = Emitter:extend()

function HierarchicalStateMachine:setStates(states)
  self.states = {}
  self.paths = {}

  function addState(name, state, parentPath)
    self.states[name] = state

    local path = clone(parentPath)
    path[#path + 1] = state
    self.paths[state] = path

    if state.substates then
      for childName, child in pairs(state.substates) do
        addState(childName, child, path)
      end
    end
  end

  for name, state in pairs(states) do
    addState(name, state, {})
  end
end

function HierarchicalStateMachine:react(...)
  local path = self.paths[self.state]
  for i = #path, 1, -1 do
    local state = path[i]
    local targetState = state.react(self, ...)
    if targetState then -- consumed
      if targetState ~= self.state then
        self:_transit(targetState)
      end
      break
    end
  end
end

function HierarchicalStateMachine:_transit(targetState)
  local lca = self:_getLCA(self.state, targetState)
  self:_runExitActions(self.state, lca)
  self:_runEntryActions(lca, targetState)
  self.state = targetState
end

function HierarchicalStateMachine:_runExitActions(sourceState, lca)
  local path = self.paths[sourceState]
  for i = #path, 1, -1 do
    local state = path[i]
    if state == lca then
      break
    end
    if state.exit then
      state.exit(self)
    end
  end
end

function HierarchicalStateMachine:_runEntryActions(lca, targetState)
  local path = self.paths[targetState]
  local i = (indexOf(path, lca) or 0) + 1
  while i <= #path do
    local state = path[i]
    if state.entry then
      state.entry(self)
    end
    i = i + 1
  end
end

function HierarchicalStateMachine:_isAncestorOf(ancestor, descendant)
  if descendant then
    local path = self.paths[descendant]
    for i = #path, 1, -1 do
      if path[i] == ancestor then
        return true
      end
    end
  end
  return false
end

function HierarchicalStateMachine:_getLCA(a, b)
  if a then
    local path = self.paths[a]
    for i = #path, 1, -1 do
      if self:_isAncestorOf(path[i], b) then
        return path[i]
      end
    end
  end
  return nil
end

hsm.StateMachine = StateMachine
hsm.HierarchicalStateMachine = HierarchicalStateMachine
return hsm

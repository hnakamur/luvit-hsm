local core = require("core")
local Emitter = core.Emitter

local hsm = {}

local StateMachine = Emitter:extend()

function StateMachine:setStates(states)
  self.states = states
end

function StateMachine:react(...)
  local state = self.states[self.stateName]
  local targetStateName = state.react(...)
  if targetStateName and targetStateName ~= self.stateName then
    self:_transit(targetStateName)
  end
end

function StateMachine:_transit(targetStateName)
  self:_runExitActions(self.stateName)
  self:_runEntryActions(targetStateName)
  self.stateName = targetStateName
end

function StateMachine:_runExitActions(sourceStateName)
  local sourceState = self.states[sourceStateName]
  if sourceState.exit then
    sourceState.exit()
  end
end

function StateMachine:_runEntryActions(targetStateName)
  local targetState = self.states[targetStateName]
  if targetState.entry then
    targetState.entry()
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
    path[#path + 1] = name
    self.paths[name] = path

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
  local path = self.paths[self.stateName]
  for i = #path, 1, -1 do
    local state = self.states[path[i]]
    local targetStateName = state.react(...)
    if targetStateName ~= nil then -- consumed
      if targetStateName ~= self.stateName then
        self:_transit(targetStateName)
      end
      break
    end
  end
end

function HierarchicalStateMachine:_transit(targetStateName)
  local lca = self:_getLCA(self.stateName, targetStateName)
  self:_runExitActions(self.stateName, lca)
  self:_runEntryActions(lca, targetStateName)
  self.stateName = targetStateName
end

function HierarchicalStateMachine:_runExitActions(sourceStateName, lca)
  local path = self.paths[sourceStateName]
  for i = #path, 1, -1 do
    local stateName = path[i]
    if stateName == lca then
      break
    end
    local state = self.states[stateName]
    if state.exit then
      state.exit()
    end
  end
end

function HierarchicalStateMachine:_runEntryActions(lca, targetStateName)
  local path = self.paths[targetStateName]
  local i = (indexOf(path, lca) or 0) + 1
  while i <= #path do
    local state = self.states[path[i]]
    if state.entry then
      state.entry()
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

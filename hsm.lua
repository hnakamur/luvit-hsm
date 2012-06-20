local core = require("core")
local Object = core.Object

local hsm = {}

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

local function isAncestorOf(ancestor, descendant)
  if descendant then
    local path = descendant.path
    for i = #path, 1, -1 do

      if path[i] == ancestor then
        return true
      end
    end
  end
  return false
end

local function getLCA(a, b)
  if a then
    local path = a.path
    for i = #path, 1, -1 do
      if isAncestorOf(path[i], b) then
        return path[i]
      end
    end
  end
  return nil
end

local StateMachine = Object:extend()

function StateMachine:initialize(opts)
  if opts.states then
    self:setStates(opts.states)
  end
  if opts.initStateName then
    self.state = self.statesMap[opts.initStateName]
  end
end

function StateMachine:setStates(states)
  local statesMap = {}

  function addState(name, state, parentPath)
    statesMap[name] = state
    state.name = name

    local path = clone(parentPath)
    path[#path + 1] = state
    state.path = path

    if state.substates then
      for childName, child in pairs(state.substates) do
        addState(childName, child, path)
      end
    end
  end

  if states then
    for name, state in pairs(states) do
      addState(name, state, {})
    end
  end

  self.states = states
  self.statesMap = statesMap
end

function StateMachine:react(...)
  local path = self.state.path
  for i = #path, 1, -1 do
    local state = path[i]
    local targetStateName = state.react(...)
    if targetStateName ~= nil then -- consumed
      if targetStateName ~= state.name then
        self:_transit(targetStateName)
      end
      break
    end
  end
end

function StateMachine:_transit(targetStateName)
  local targetState = self.statesMap[targetStateName]
  local lca = getLCA(self.state, targetState)
  self:_runExitActions(self.state, lca)
  self:_runEntryActions(lca, targetState)
  self.state = targetState
end

function StateMachine:_runExitActions(sourceState, lca)
  local path = sourceState.path
  for i = #path, 1, -1 do
    local s = path[i]
    if s == lca then
      break
    end
    if s.exit then
      s.exit()
    end
  end
end

function StateMachine:_runEntryActions(lca, targetState)
  local path = targetState.path
  local i = (indexOf(path, lca) or 0) + 1
  while i <= #path do
    local s = path[i]
    if s.entry then
      s.entry()
    end
    i = i + 1
  end
end

hsm.StateMachine = StateMachine
hsm.isAncestorOf = isAncestorOf
hsm.getLCA = getLCA
return hsm

local exports = {}

local string = require('string')
local hsm = require('../hsm.lua')
local HierarchicalStateMachine = hsm.HierarchicalStateMachine

exports['isAncestorOf'] = function (test)
  local machine = HierarchicalStateMachine:new{
    states = {
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
  }
  local e = machine.states.e
  local d = machine.states.d
  local a = machine.states.a

  test.equal(false, hsm.isAncestorOf(e, nil))
  test.equal(true, hsm.isAncestorOf(e, e))
  test.equal(true, hsm.isAncestorOf(d, e))
  test.equal(true, hsm.isAncestorOf(a, e))
  test.done()
end

exports['getLCA'] = function (test)
  local machine = HierarchicalStateMachine:new{
    states = {
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
  }
  local e = machine.states.e
  local d = machine.states.d
  local a = machine.states.a

  test.ok(hsm.getLCA(e, nil) == nil)
  test.ok(hsm.getLCA(e, d) == d)
  test.ok(hsm.getLCA(d, e) == d)
  test.ok(hsm.getLCA(e, c) == b)
  test.done()
end

return exports

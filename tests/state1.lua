local exports = {}

local string = require('string')
local hsm = require('../hsm.lua')
local StateMachine = hsm.StateMachine

exports['isAncestorOf'] = function (test)
  local machine = StateMachine:new{
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
  local e = machine.statesMap.e
  local d = machine.statesMap.d
  local a = machine.statesMap.a

  test.equal(false, hsm.isAncestorOf(e, nil))
  test.equal(true, hsm.isAncestorOf(e, e))
  test.equal(true, hsm.isAncestorOf(d, e))
  test.equal(true, hsm.isAncestorOf(a, e))
  test.done()
end

exports['getLCA'] = function (test)
  local machine = StateMachine:new{
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
  local e = machine.statesMap.e
  local d = machine.statesMap.d
  local a = machine.statesMap.a

  test.ok(hsm.getLCA(e, nil) == nil)
  test.ok(hsm.getLCA(e, d) == d)
  test.ok(hsm.getLCA(d, e) == d)
  test.ok(hsm.getLCA(e, c) == b)
  test.done()
end

return exports

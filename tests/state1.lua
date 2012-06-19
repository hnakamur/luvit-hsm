local exports = {}

local string = require('string')
local histm = require('../histm.lua')
local StateMachine = histm.StateMachine

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

  test.equal(false, histm.isAncestorOf(e, nil))
  test.equal(true, histm.isAncestorOf(e, e))
  test.equal(true, histm.isAncestorOf(d, e))
  test.equal(true, histm.isAncestorOf(a, e))
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

  test.ok(histm.getLCA(e, nil) == nil)
  test.ok(histm.getLCA(e, d) == d)
  test.ok(histm.getLCA(d, e) == d)
  test.ok(histm.getLCA(e, c) == b)
  test.done()
end

return exports

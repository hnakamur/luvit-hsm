local exports = {}

local string = require('string')
local histm = require('../histm.lua')
local State = histm.State

exports['State:isAncestorOf'] = function (test)
  local e = State:new()
  local d = State:new{e}
  local c = State:new()
  local b = State:new{c, d}
  local a = State:new{b}

  test.equal(false, e:isAncestorOf(nil))
  test.equal(true, e:isAncestorOf(e))
  test.equal(true, d:isAncestorOf(e))
  test.equal(true, a:isAncestorOf(e))
  test.done()
end

exports['State:getLCA'] = function (test)
  local e = State:new()
  e.name = 'e'
  local d = State:new{e}
  d.name = 'd'
  local c = State:new()
  c.name = 'c'
  local b = State:new{c, d}
  b.name = 'b'
  local a = State:new{b}
  a.name = 'a'

  test.ok(e:getLCA(nil) == nil)
  test.ok(e:getLCA(d) == d)
  test.ok(d:getLCA(e) == d)
  test.ok(e:getLCA(c) == b)
  test.done()
end

return exports

module map

import base
import ck/map

pub fun main()
  test("contains")
    val m = [5, 2, 9, 0, 8, 4, 7, 6, 3, 1].foldl(map/empty, fn(m, v) m.insert(v, v))
    expect(m.contains(0), True)
    expect(m.contains(3), True)
    expect(m.contains(8), True)
    expect(m.contains(-1), False)
    expect(m.contains(11), False)
  test("update")
    val m = [5, 2, 9, 0, 8, 4, 7, 6, 3, 1].foldl(map/empty, fn(m, v) m.insert(v, v))
    val m' = m.update(3, fn(o) o.maybe(100, fn(v) v * v))
    expect(m'.get(3), Just(9))
    for(10) fn(k)
      if k != 3 then expect(m'.get(k), Just(k))
  test("update (nonexistent)")
    val m = [5, 2, 9, 0, 8, 4, 7, 6, 3, 1].foldl(map/empty, fn(m, v) m.insert(v, v))
    val m' = m.update(10, fn(o) o.maybe(100, fn(v) v * v))
    expect(m'.get(10), Just(100))
    for(10) fn(k)
      expect(m'.get(k), Just(k))

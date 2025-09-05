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

module fenwick

import base
import ck/fenwick

pub fun main()
  test("prefix-sum and add")
    val f = fenwick(10)
    for(1, 10) fn(i)
      expect(f.prefix-sum(i), 0)
    f.add(3, 5)
    for(1, 10) fn(i)
      expect(f.prefix-sum(i), if i < 3 then 0 else 5)
    f.add(8, 12)
    for(1, 10) fn(i)
      expect(f.prefix-sum(i), if i < 3 then 0 else if i < 8 then 5 else 17)

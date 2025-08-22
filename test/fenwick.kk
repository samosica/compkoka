module fenwick

import base
import ck/algebra/monoid
import ck/fenwick

pub fun main()
  test("prefix-sum and add")
    fun proc(?monoid)
      // Note: `fenwick`, `prefix-sum`, and `add` use `?monoid`, the implicit
      //       parameter of `proc` according to _inner scope rule_. See
      //       <https://github.com/koka-lang/koka/blob/00399ab232430879995ca1b2d7442bfa53eb826e/samples/learn/implicits.kk#L113>.
      val f = fenwick(10)
      for(1, 10) fn(i)
        expect(f.prefix-sum(i), 0)
      f.add(3, 5)
      for(1, 10) fn(i)
        expect(f.prefix-sum(i), if i < 3 then 0 else 5)
      f.add(8, 12)
      for(1, 10) fn(i)
        expect(f.prefix-sum(i), if i < 3 then 0 else if i < 8 then 5 else 17)
    proc(?monoid=int/add/monoid)

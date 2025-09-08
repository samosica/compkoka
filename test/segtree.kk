module segtree

import base
import ck/algebra/monoid
import ck/segtree

pub fun main()
  test("segtree")
    fun proc(?monoid)
      val seg = segtree(10)
      for(10) fn(l)
        for(l + 1, 10) fn(r)
          expect(seg.product(l, r), 0)
    proc(?monoid=int/add/monoid)
  test("list/segtree")
    fun proc(?monoid)
      val n = 15
      val seg = segtree(list(0, n - 1))
      for(n) fn(l)
        for(l + 1, n) fn(r)
          expect(seg.product(l, r), (r - 1) * r / 2 - (l - 1) * l / 2)
    proc(?monoid=int/add/monoid)
  test("vector/segtree")
    fun proc(?monoid)
      val n = 15
      val seg = segtree(list(0, n - 1).vector)
      for(n) fn(l)
        for(l + 1, n) fn(r)
          expect(seg.product(l, r), (r - 1) * r / 2 - (l - 1) * l / 2)
    proc(?monoid=int/add/monoid)
  test("set(8)")
    fun proc(?monoid)
      val n = 8
      val seg = segtree(n)
      val qs = [(0, 1), (5, 21)]
      qs.foreach fn((i, v))
        seg.set(i, v)
      for(n) fn(l)
        for(l + 1, n) fn(r)
          expect(
            seg.product(l, r),
            qs.filter(fn((i, _)) l <= i && i < r).map(snd).sum
          )
    proc(?monoid=int/add/monoid)
  test("set(10)")
    fun proc(?monoid)
      val n = 10
      val seg = segtree(n)
      val qs = [(0, 4), (6, 6)]
      qs.foreach fn((i, v))
        seg.set(i, v)
      for(n) fn(l)
        for(l + 1, n) fn(r)
          expect(
            seg.product(l, r),
            qs.filter(fn((i, _)) l <= i && i < r).map(snd).sum
          )
    proc(?monoid=int/add/monoid)
  test("set(11)")
    fun proc(?monoid)
      val n = 11
      val seg = segtree(n)
      val qs = [(1, 3), (10, 30)]
      qs.foreach fn((i, v))
        seg.set(i, v)
      for(n) fn(l)
        for(l + 1, n) fn(r)
          expect(
            seg.product(l, r),
            qs.filter(fn((i, _)) l <= i && i < r).map(snd).sum
          )
    proc(?monoid=int/add/monoid)
  // Ensure that `set` does not perform invalid operations like
  // `(monoid.mul)(Just((1, 3)), Just((2, 5)))`.
  test("set(17, range union)")
    val monoid: monoid<maybe<(int,int)>> =
      Monoid(
        one=Nothing,
        mul=fn(o1, o2) {
          match (o1, o2)
            (Nothing, _) -> o2
            (_, Nothing) -> o1
            (Just((l1, r1)), Just((l2, r2))) ->
              assert("r1 must be equal to l2", r1 == l2)
              Just((l1, r2))
        }
      )
    val n = 17
    val seg = segtree(list(0, n - 1).map(fn(i) Just((i, i + 1))))
    for(n) fn(i)
      seg.set(i, Just((i, i + 1)))
    for(n) fn(l)
      for(l + 1, n) fn(r)
        expect(
          seg.product(l, r),
          Just((l, r)),
          ?(==)=fn(o1, o2) maybe/(==)(
            o1,
            o2,
            ?(==)=fn(p1, p2) tuple2/(==)(p1, p2, ?fst/(==)=int/(==), ?snd/(==)=int/(==))
          )
        )

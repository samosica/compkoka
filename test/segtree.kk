module segtree

import base
import ck/algebra/monoid
import ck/segtree

// TODO: move this monoid into algebra/monoid
val nat/max/monoid: monoid<int> = Monoid(one=0, mul=max)

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
  test("binsearch(max, 8)")
    fun proc(?monoid)
      val n = 8
      val seg = segtree(n)
      val v = [2, 4, 3, 0, 7, 6, 1, 5].vector
      for(n) fn(i)
        seg.set(i, v[i])
      for(-1, n) fn(x)
        for(n) fn(l)
          for(l, n) fn(r)
            // Find the first element greater than or equal to x in [l, r)
            expect(
              seg.binsearch(l, r, fn(mx) mx >= x),
              list(l, r - 1).find(fn(i) v[i] >= x).default(r)
            )
    proc(?monoid=nat/max/monoid)
  test("binsearch(max, 11)")
    fun proc(?monoid)
      val n = 11
      val seg = segtree(n)
      val v = [1, 6, 5, 3, 7, 4, 8, 10, 2, 9, 0].vector
      for(n) fn(i)
        seg.set(i, v[i])
      for(-1, n) fn(x)
        for(n) fn(l)
          for(l, n) fn(r)
            // Find the first element greater than or equal to x in [l, r)
            expect(
              seg.binsearch(l, r, fn(mx) mx >= x),
              list(l, r - 1).find(fn(i) v[i] >= x).default(r)
            )
    proc(?monoid=nat/max/monoid)
  test("binsearch(add, 8)")
    fun proc(?monoid)
      val n = 8
      val seg = segtree(n)
      val v = [2, 4, 3, 0, 7, 6, 1, 5].vector
      for(n) fn(i)
        seg.set(i, v[i])
      val range-sum = fn(l: int, r: int) list(l, r).map(fn(i) v[i]).sum
      for(-1, n * (n - 1) / 2 + 1) fn(x)
        for(n) fn(l)
          for(l, n) fn(r)
            expect(
              seg.binsearch(l, r, fn(sum) sum >= x),
              list(l, r - 1).find(fn(i) range-sum(l, i) >= x).default(r)
            )
    proc(?monoid=int/add/monoid)

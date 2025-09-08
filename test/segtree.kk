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

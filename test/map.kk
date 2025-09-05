module map

import base
import ck/map

pub fun main()
  test("contains")
    val m = [5, 2, 9, 0, 8, 4, 7, 6, 3, 1].foldl(map/empty, fn(m, v) m.add(v, v))
    expect(m.contains(0), True)
    expect(m.contains(3), True)
    expect(m.contains(8), True)
    expect(m.contains(-1), False)
    expect(m.contains(11), False)
  test("add")
    val m = [5, 2, 9, 0, 8, 4, 7, 6, 3, 1].foldl(map/empty, fn(m, v) m.add(v, v))
    for(10) fn(k)
      expect(m.get(k), Just(k))
    expect(m.size, 10)
  test("add (duplicates)")
    val m = [(1, 1), (0, 1), (2, 1), (0, 2), (2, 2), (1, 2)]
      .foldl(map/empty, fn(m, (k, v)) m.add(k, v))
    for(3) fn(k)
      expect(m.get(k), Just(2))
    expect(m.size, 3)
  test("remove")
    var m := [5, 2, 9, 0, 8, 4, 7, 6, 3, 1].foldl(map/empty, fn(m, v) m.add(v, v))

    m := m.remove(5)
    expect(m.contains(5), False)
    for(10) fn(k)
      if k != 5 then expect(m.get(k), Just(k))
    expect(m.size, 9)

    m := m.remove(9)
    expect(m.contains(5), False)
    expect(m.contains(9), False)
    for(10) fn(k)
      if k != 5 && k != 9 then expect(m.get(k), Just(k))
    expect(m.size, 8)

    m := m.remove(9)
    expect(m.contains(5), False)
    expect(m.contains(9), False)
    for(10) fn(k)
      if k != 5 && k != 9 then expect(m.get(k), Just(k))
    expect(m.size, 8)
  test("update")
    val m = [5, 2, 9, 0, 8, 4, 7, 6, 3, 1].foldl(map/empty, fn(m, v) m.add(v, v))
    val m' = m.update(3, fn(o) o.maybe(100, fn(v) v * v))
    expect(m'.get(3), Just(9))
    for(10) fn(k)
      if k != 3 then expect(m'.get(k), Just(k))
    expect(m'.size, 10)
  test("update (nonexistent)")
    val m = [5, 2, 9, 0, 8, 4, 7, 6, 3, 1].foldl(map/empty, fn(m, v) m.add(v, v))
    val m' = m.update(10, fn(o) o.maybe(100, fn(v) v * v))
    expect(m'.get(10), Just(100))
    for(10) fn(k)
      expect(m'.get(k), Just(k))
    expect(m'.size, 11)
  test("foreach")
    val m = [5, 2, 9, 0, 8, 4, 7, 6, 3, 1].foldl(map/empty, fn(m, v) m.add(v, v))
    var l := []
    m.foreach fn(k, v)
      l := Cons((k, v), l)
    // Arrange elements in chronological order
    l := l.reverse
    expect(
      l,
      list(0, 9).map(fn(i) (i, i)),
      // Note: the following lines are necessary for Koka v3.1.3 and earlier versions.
      ?(==)=fn(l1, l2)
        list/(==)(
          l1,
          l2,
          ?(==)=fn(p1, p2) tuple2/(==)(p1, p2, ?fst/(==)=int/(==), ?snd/(==)=int/(==))
        )
    )
  test("foreach-key")
    val m = [5, 2, 9, 0, 8, 4, 7, 6, 3, 1].foldl(map/empty, fn(m, v) m.add(v, v))
    var l := []
    m.foreach-key fn(k)
      l := Cons(k, l)
    // Arrange elements in chronological order
    l := l.reverse
    expect(l, list(0, 9))

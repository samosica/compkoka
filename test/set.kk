module set

import base
import ck/set

pub fun main()
  test("add")
    val s = [5, 2, 9, 0, 8, 4, 7, 6, 3, 1].foldl(set/empty, fn(s, v) s.add(v))
    for(10) fn(i)
      expect(s.contains(i), True)
    expect(s.size, 10)
  test("add (duplicates)")
    val s = [1, 0, 2, 0, 2, 1]
      .foldl(set/empty, fn(s, v) s.add(v))
    for(3) fn(i)
      expect(s.contains(i), True)
    expect(s.size, 3)
  test("remove")
    var s := [5, 2, 9, 0, 8, 4, 7, 6, 3, 1].foldl(set/empty, fn(s, v) s.add(v))

    s := s.remove(5)
    expect(s.contains(5), False)
    for(10) fn(i)
      if i != 5 then expect(s.contains(i), True)
    expect(s.size, 9)

    s := s.remove(9)
    expect(s.contains(5), False)
    expect(s.contains(9), False)
    for(10) fn(i)
      if i != 5 && i != 9 then expect(s.contains(i), True)
    expect(s.size, 8)

    s := s.remove(9)
    expect(s.contains(5), False)
    expect(s.contains(9), False)
    for(10) fn(i)
      if i != 5 && i != 9 then expect(s.contains(i), True)
    expect(s.size, 8)
  test("foreach")
    val s = [5, 2, 9, 0, 8, 4, 7, 6, 3, 1].foldl(set/empty, fn(s, v) s.add(v))
    var l := []
    s.foreach fn(v)
      l := Cons(v, l)
    // Arrange elements in chronological order
    l := l.reverse
    expect(l, list(0, 9))

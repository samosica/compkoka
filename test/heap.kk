module heap

import std/core/list
import base
import ck/heap

pub fun main()
  test("100")
    // a shuffled sequence of integers from 0 to 99
    val l = [
      20, 40, 73, 79, 68, 13, 97, 98, 76, 50,
      60, 26,  4,  2, 15, 41, 81, 53, 47, 93,
      23, 74,  0, 17,  7, 44, 83, 51, 84, 28,
      86, 89, 52, 32, 14, 91, 34, 12, 49, 80,
      66, 63, 65, 54, 71, 78,  6, 37, 59, 43,
      85, 64, 61, 18, 88, 92, 27, 72,  5, 19,
      31, 36, 42,  8, 45, 69, 58, 87, 16, 22,
       1, 30, 11,  3, 70, 33, 67, 99, 95, 38,
      48, 21, 94, 75, 62, 90, 46, 55, 10, 56,
      82, 77, 96, 25, 39, 24, 29,  9, 57, 35
    ]
    var h := heap/empty()
    foreach(l) fn(i)
      h := h.insert(i)
    var minis-rev := []
    while { !h.is-empty }
      val mini = h.min
      expect(mini.is-just, True)
      minis-rev := Cons(h.min.unjust, minis-rev)
      h := h.remove-min
    val minis = minis-rev.reverse
    expect(minis, list(0, 99))
  test("duplicates")
    var h := heap/empty()
    h := h.insert(0)
    h := h.insert(0)
    expect(h.min, Just(0))
    h := h.remove-min
    expect(h.min, Just(0))
    h := h.remove-min
    expect(h.min, Nothing)

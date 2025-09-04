module vector

import std/core/unsafe
import std/core/vector
import std/num/float64
import base
import ck/vector

pub fun main()
  test("sort")
    val v = [
      10, 86, 27, 95, 78, 60, 53, 52, 80,  9,
      26, 59, 83, 39, 94,  5, 35, 36, 72, 87,
       3, 74, 22, 11, 85, 62,  7, 51, 89, 57,
      64, 19, 63, 99, 81, 71, 33, 29, 50, 17,
       0, 14,  4, 13, 24, 42, 82, 30, 98, 76,
      69, 12, 79, 68, 28, 91, 77, 43, 73, 54,
      93, 92, 46, 56, 40, 75, 15, 18, 31, 37,
      58, 48, 47, 61, 67, 20, 49, 96, 41, 65,
      90, 38, 32, 25, 55,  8, 34, 45, 66, 88,
       2, 21, 23, 70, 97, 84, 16, 44,  6,  1
    ].vector
    expect(v.sort.list, vector-init-total(100, fn(i) i).list)
  test("sort is stable")
    val v = [
      (21, 1), ( 9, 1), (34, 1), (10, 1), (38, 1), (41, 1), (30, 1), (45, 1), (36, 1), ( 2, 1),
      (32, 1), ( 2, 2), ( 4, 1), (43, 1), (17, 1), (15, 1), (11, 1), (11, 2), (12, 1), (42, 1),
      (23, 1), (49, 1), (14, 1), (46, 1), (10, 2), (30, 2), (21, 2), (48, 1), (24, 1), (38, 2),
      ( 5, 1), (26, 1), (22, 1), (35, 1), (35, 2), (44, 1), ( 7, 1), ( 5, 2), (25, 1), (34, 2),
      (23, 2), (26, 2), ( 8, 1), (20, 1), (31, 1), (47, 1), ( 0, 1), ( 8, 2), (33, 1), ( 6, 1),
      (39, 1), ( 6, 2), (32, 2), (46, 2), (27, 1), (37, 1), (17, 2), ( 7, 2), (18, 1), (28, 1),
      (49, 2), (33, 2), (19, 1), (40, 1), (37, 2), (13, 1), (18, 2), (16, 1), (44, 2), ( 1, 1),
      ( 9, 2), (14, 2), (28, 2), (43, 2), ( 3, 1), (19, 2), (41, 2), (29, 1), (40, 2), (27, 2),
      (48, 2), (47, 2), (20, 2), (42, 2), (45, 2), (22, 2), ( 4, 2), ( 3, 2), (31, 2), ( 1, 2),
      (29, 2), (13, 2), (25, 2), (16, 2), (36, 2), (39, 2), ( 0, 2), (24, 2), (15, 2), (12, 2)
    ].vector
    expect(v.sort(fn(p1, p2) p1.fst < p2.fst).list, vector-init-total(100, fn(i) (i / 2, i % 2 + 1)).list)
  test("z-algorithm")
    expect("abaaaba".vector.z-algorithm((==)).list, [7, 0, 1, 1, 3, 0, 1])
  test("search (short, found)")
    expect("abaaaba".vector.search("aab".vector, (==)), Just(3))
  test("search (short, not found)")
    expect("abaaaba".vector.search("abab".vector, (==)), Nothing)
  test("search (short, start != 0, not found)")
    expect("abaaaba".vector.search("aab".vector, (==), 4), Nothing)
  test("search (long)")
    val v = vector-init-total(100, fn(i) { if i == 97 then 'b' else 'a' })
    expect(v.search("ab".vector, (==)), Just(96))

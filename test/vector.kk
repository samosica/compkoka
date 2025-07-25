module vector

import std/core/unsafe
import std/core/vector
import std/num/float64
import base
import ck/vector

pub fun main()
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

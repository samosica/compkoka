module binsearch

import std/num/float64
import base
import ck/binsearch

pub fun main()
  test("binsearch")
    expect(binsearch(0, 200, fn(x) { x <= 87 }), 87)
  test("binsearch-f64")
    // Calculate an approximate value of sqrt 2
    val actual = binsearch-f64(0.0, 2.0, 30, fn(x) { x * x <= 2.0 })
    val diff = (actual - flt-sqrt2).abs
    expect(diff <= 1e-6, True)

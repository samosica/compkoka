module math

import base
import ck/math
import ck/io

fun detect-exception(action: () -> <exn|e> a): e bool
  try { action(); False } fn(_) { True }

pub fun main()
  test("divisible-count(small)")
    expect(24.divisible-count(2), 3)
    expect(24.divisible-count(3), 1)
    expect(24.divisible-count(5), 0)
  test("divisible-count(negative)")
    expect((-24).divisible-count(2), 3)
    expect(24.divisible-count(-3), 1)
    expect((-60).divisible-count(-5), 1)
  test("divisible-count(|d| <= 1)")
    expect(detect-exception({ 24.divisible-count(1) }), True)
    expect(detect-exception({ 24.divisible-count(0) }), True)
    expect(detect-exception({ 24.divisible-count(-1) }), True)
  test("floor-log(2)")
    val n = 2
    for(n, 1000) fn(i)
      val l = i.floor-log(n)
      expect(n.pow(l) <= i && i < n.pow(l + 1), True)
  test("floor-log(4)")
    val n = 4
    for(n, 1000) fn(i)
      val l = i.floor-log(n)
      expect(n.pow(l) <= i && i < n.pow(l + 1), True)
  test("floor-log(5)")
    val n = 5
    for(n, 1000) fn(i)
      val l = i.floor-log(n)
      expect(n.pow(l) <= i && i < n.pow(l + 1), True)
  test("floor-log(base <= 2)")
    expect(detect-exception({ 3.floor-log(1) }), True)
    expect(detect-exception({ 3.floor-log(0) }), True)
    expect(detect-exception({ 3.floor-log(-1) }), True)
  test("ceil-log(2)")
    val n = 2
    for(n, 1000) fn(i)
      val l = i.ceil-log(n)
      expect(n.pow(l - 1) < i && i <= n.pow(l), True)
  test("ceil-log(4)")
    val n = 4
    for(n, 1000) fn(i)
      val l = i.ceil-log(n)
      expect(n.pow(l - 1) < i && i <= n.pow(l), True)
  test("ceil-log(5)")
    val n = 5
    for(n, 1000) fn(i)
      val l = i.ceil-log(n)
      expect(n.pow(l - 1) < i && i <= n.pow(l), True)
  test("ceil-log(base <= 2)")
    expect(detect-exception({ 3.ceil-log(1) }), True)
    expect(detect-exception({ 3.ceil-log(0) }), True)
    expect(detect-exception({ 3.ceil-log(-1) }), True)

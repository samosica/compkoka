module math

import base
import ck/math
import ck/io

fun detect-exception(action: () -> <exn|e> a): e bool
  try { action(); False } fn(_) { True }

// Note: Koka adopts the division operator of integers that always returns
// nonnegative reminder but not the one that truncates the fraction of given
// arguments towards negative infinity. See <https://koka-lang.github.io/koka/doc/std_core_int.html#divmod>.

fun floor-div(a: int, b: int): int
  if b < 0 then (~a) / (~b) else a / b

fun naive-floor-sum(n: int, a: int, b: int, d: int): int
  list(0, n - 1).map(fn(i) floor-div(a * i + b, d)).sum

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
  test("floor-sum(5, 3, 8, 4)")
    val n = 5
    val a = 3
    val b = 8
    val d = 4
    expect(floor-sum(n, a, b, d), naive-floor-sum(n, a, b, d))
  test("floor-sum(5, -3, 8, 4)")
    val n = 5
    val a = -3
    val b = 8
    val d = 4
    expect(floor-sum(n, a, b, d), naive-floor-sum(n, a, b, d))
  test("floor-sum(5, 3, -8, 4)")
    val n = 5
    val a = 3
    val b = -8
    val d = 4
    expect(floor-sum(n, a, b, d), naive-floor-sum(n, a, b, d))
  test("floor-sum(5, -3, -8, 4)")
    val n = 5
    val a = -3
    val b = -8
    val d = 4
    expect(floor-sum(n, a, b, d), naive-floor-sum(n, a, b, d))
  test("floor-sum(5, 3, 8, -4)")
    val n = 5
    val a = 3
    val b = 8
    val d = -4
    expect(floor-sum(n, a, b, d), naive-floor-sum(n, a, b, d))
  test("floor-sum(1000, -5, 7, 10)")
    val n = 1000
    val a = -5
    val b = 7
    val d = 10
    expect(floor-sum(n, a, b, d), naive-floor-sum(n, a, b, d))
  test("floor-sum(1000, 5, -7, 10)")
    val n = 1000
    val a = 5
    val b = -7
    val d = 10
    expect(floor-sum(n, a, b, d), naive-floor-sum(n, a, b, d))
  test("floor-sum(10000, 1001, 997, 301)")
    val n = 10000
    val a = 1001
    val b = 997
    val d = 301
    expect(floor-sum(n, a, b, d), naive-floor-sum(n, a, b, d))

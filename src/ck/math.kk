// Math
module ck/math

import std/core/undiv

pub fun divisible-count(n: int, d: int): exn int
  inline fun loop(i: int): int
    if i % d == 0 then
      loop((i / d).pretend-decreasing) + 1
    else
      0
  if d.abs <= 1 then
    "d must satisfy the condition abs(d) >= 2".throw
  else
    loop(n)

pub fun floor-log(n: int, base: int): exn int
  inline fun loop(i: int): int
    if i < base then
      0
    else
      loop((i / base).pretend-decreasing) + 1
  if base <= 1 then
    "base must be greater than or equal to 2".throw
  else
    loop(n)

pub fun ceil-log(n: int, base: int): exn int
  inline fun loop(i: int): int
    if i <= 1 then
      0
    else
      loop(((i + base - 1) / base).pretend-decreasing) + 1
  if base <= 1 then
    "base must be greater than or equal to 2".throw
  else
    loop(n)

// References:
// - <https://rsk0315.hatenablog.com/entry/2020/12/13/231307>
// - <https://github.com/atcoder/ac-library>

// Assume that the first three parameters are nonnegative and the remaining one
// is positive.
fun floor-sum-intl(n: int, a: int, b: int, d: int)
  if a >= d then
    floor-sum-intl(n.pretend-decreasing, a % d, b, d) + a / d * (n * (n - 1) / 2)
  else if b >= d then
    floor-sum-intl(n.pretend-decreasing, a, b % d, d) + b / d * n
  else
    val n-max = a * (n - 1) + b
    if n-max < d then
      0
    else
      val (q-max, r-max) = divmod(n-max, d)
      q-max + floor-sum-intl(q-max.pretend-decreasing, d, r-max, a)

// The sum of floor((ai + b) / d) for all i = 0, …, n - 1.
// Assume that `n >= 0` and `d != 0`.
pub fun floor-sum(n: int, a: int, b: int, d: int)
  if d < 0 then return floor-sum(n.pretend-decreasing, ~a, ~b, ~d)
  assert("n must be nonnegative", n >= 0)
  assert("d must not be zero", d != 0)
  val a' = a % d
  val b' = b % d
  (a - a') / d * (n * (n - 1) / 2)
    + (b - b') / d * n
    + floor-sum-intl(n, a', b', d)

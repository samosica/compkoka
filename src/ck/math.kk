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

pub fun extgcd(a: int, b: int)
  fun loop(a': int, b': int, s: int, t: int, s': int, t': int)
    if b' == 0 then return (s, t, a')
    loop(b', a' % b', s', t', s - (a' / b') * s', t - (a' / b') * t')
  loop(a, b, 1, 0, 0, 1)

// The number of combinations modulo `modulus`.
// Assume that every prime factor of `modulus` is greater than `min(k, n - k)`.
pub fun mod-comb(n: int, k: int, modulus: int)
  if n < 0 || k < 0 || n < k then return 0
  var res := 1
  val k' = k.min(n - k)
  for(1, k') fn(i)
    val (inv-i, _, _) = extgcd(i, modulus)
    val inv-i' = if inv-i >= 0 then inv-i else inv-i + modulus
    // Note: after this update, res = n choose i (mod modulus)
    res := res * (n + 1 - i) % modulus * inv-i' % modulus
  res

// `0!, 1!, ..., max-n! (mod modulus)`
pub fun factorial(max-n: int, modulus: int): exn vector<int>
  var res := vector(max-n + 1, 0)
  res[0] := 1
  for(1, max-n) fn(i)
    res[i] := res[i - 1] * i % modulus
  res

// `(0!)^{-1}, (1!)^{-1}, ..., ((fact.length - 1)!)^{-1} (mod modulus)`.
// Calculate these values using a vector of factorials `fact`.
// Assume that every prime factor of `modulus` is greater than `fact.length - 1`.
pub fun inv-factorial(fact: vector<int>, modulus: int): pure vector<int>
  val max-n = fact.length - 1
  var res := vector(max-n + 1, 0)
  val (inv-fact-max-n, _, _) = extgcd(fact[max-n], modulus)
  res[max-n] := (if inv-fact-max-n >= 0 then inv-fact-max-n else inv-fact-max-n + modulus)
  for(max-n) fn(i)
    val j = max-n - i
    res[j - 1] := res[j] * j % modulus
  res

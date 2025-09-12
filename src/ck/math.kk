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

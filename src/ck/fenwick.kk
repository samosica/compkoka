// Fenwick tree
module ck/fenwick

import std/num/int64
import std/core/undiv
import std/core/unsafe
import ck/algebra/monoid

abstract struct fenwick<h,a>
  tree: ref<h,vector<a>>

// Create a Fenwick tree
pub fun fenwick(size: int, ?monoid: monoid<a>): alloc<h> fenwick<h,a>
  Fenwick(ref(vector(size + 1, monoid.one)))

pub inline fun size(f: fenwick<h,a>): <div,read<h>> int
  (!f.tree).length - 1

// Find the rightmost 1 of the binary representation of `x`.
// Return 0 if `x` = 0.
// `x` must be within [-2^63, 2^63 - 1), the range of 64-bit signed integers.
fun rightmost-one(x: int)
  (x.int64.and(x.negate.int64)).int

// Add a value to an element.
// The first element is at position 1 (1-based).
// Raise an exception if `index` <= 0 or `index` > `f.size`.
pub fun add(f: fenwick<h,a>, index: int, value: a, ?monoid: monoid<a>): <div,exn,read<h>,write<h>> ()
  val s = f.size
  if index <= 0 || index > s then "out of bounds".throw
  f.tree.modify fn(t)
    fun loop(i)
      if i <= s then
        t[i] := (?monoid.mul)(t[i], value)
        loop((i + i.rightmost-one).pretend-decreasing)
    loop(index)

// Return the sum from the first element to the `end`-th element (inclusive).
// The first element is at position 1 (1-based).
// For convenience, return 0 if `end` = 0.
// Raise an exception if `end` < 0 or `end` > `f.size`.
pub fun prefix-sum(f: fenwick<h,a>, end: int, ?monoid: monoid<a>): <div,exn,read<h>> a
  if end < 0 || end > f.size then "out of bounds".throw
  fun loop(i, sum)
    if i > 0 then
      loop(
        (i - i.rightmost-one).pretend-decreasing,
        (?monoid.mul)(sum, (!f.tree)[i])
      )
    else
      sum
  loop(end, ?monoid.one)

/* Segment tree

Segment tree is a data structure for efficient range operations on sequences.

Notes:

- A binary operation to be used may be a partial function as long as it can be
  applied to any consecutive elements in a sequence. Hence `segtree` can handle
  matrix production and range union.

Usage:

```
import ck/algebra/monoid
import ck/segtree

fun main()
  val seg = segtree(10, ?monoid=int/add/monoid)

  seg.set(1, 3, ?monoid=int/add/monoid)
  seg.set(3, 8, ?monoid=int/add/monoid)
  seg.product(0, 10, ?monoid=int/add/monoid).println // 11
```
\/
*/
module ck/segtree

import std/core/int
import std/core/undiv
import ck/algebra/monoid

abstract value struct segtree<h,a>
  prod : ref<h,vector<a>>
  leaf-count : int

fun floor-log(n: int, base: int): int
  if n < base then
    0
  else
    floor-log((n / base).pretend-decreasing, base) + 1

// Create a segment tree
pub fun segtree(n: int, ?monoid: monoid<a>): alloc<h> segtree<h,a>
  Segtree(
    ref(vector(n * 2, ?monoid.one)),
    n
  )

// Note: `@unsafe-vector` is introduced in Koka v3.1.3.

// Unsafe function.
// This function is an internal function in the standard library.
// See <https://koka-lang.github.io/koka/doc/std_core_vector.html>
inline extern unsafe-vector(n: ssize_t): total vector<a>
  c inline "kk_vector_alloc(#1, kk_box_null(), kk_context())"

pub fun list/segtree(l: list<a>, ?monoid: monoid<a>): <alloc<h>,div,exn> segtree<h,a>
  val n = l.length
  var prod := unsafe-vector((n * 2).ssize_t)
  l.foreach-indexed fn(i, v)
    prod[i + n] := v
  inline fun loop(left: int, right: int)
    if right <= left then return ()
    for(left, right - 1) fn(i)
      prod[i] := (?monoid.mul)(prod[i * 2], prod[i * 2 + 1])
    loop(((left + 1) / 2).pretend-decreasing, right / 2)
  loop((n + 1) / 2, n)
  Segtree(ref(prod), n)

pub fun vector/segtree(v: vector<a>, ?monoid: monoid<a>): <alloc<h>,div,exn> segtree<h,a>
  val n = v.length
  var prod := unsafe-vector((n * 2).ssize_t)
  for(n) fn(i)
    prod[i + n] := v[i]
  inline fun loop(left: int, right: int)
    if right <= left then return ()
    for(left, right - 1) fn(i)
      prod[i] := (?monoid.mul)(prod[i * 2], prod[i * 2 + 1])
    loop(((left + 1) / 2).pretend-decreasing, right / 2)
  loop((n + 1) / 2, n)
  Segtree(ref(prod), n)

// Get the `k`-th element.
// The first element is at position 0 (0-based).
pub fun @index(^seg: segtree<h,a>, ^k: int): <read<h>,div,exn> a
  (!seg.prod)[k + seg.leaf-count]

inline fun recalc(seg: segtree<h,a>, k: int, ?monoid: monoid<a>): <read<h>,write<h>,div,exn> ()
  seg.prod.modify fn(prod)
    inline fun loop(i: int, start: int, invalid-start: bool)
      if i == 0 || invalid-start && i == start then
        return ()
      prod[i] := (?monoid.mul)(prod[i * 2], prod[i * 2 + 1])
      loop((i / 2).pretend-decreasing, start / 2, invalid-start || start % 2 == 1)
    val s =
      if k >= seg.leaf-count.floor-log(2).inc.exp2 then
        seg.leaf-count * 2
      else
        seg.leaf-count
    loop(k / 2, s / 2, s % 2 == 1)

// Set a value to an element.
// The first element is at position 0 (0-based).
pub fun set(seg: segtree<h,a>, k: int, v: a, ?monoid: monoid<a>): <read<h>,write<h>,div,exn> ()
  val k' = k + seg.leaf-count
  seg.prod.modify fn(prod) { prod[k'] := v }
  seg.recalc(k')

// Apply a function to an element.
// The first element is at position 0 (0-based).
pub fun update(
  seg: segtree<h,a>,
  k: int,
  f: forall<h1> a -> <local<h1>,div,exn|e> a,
  ?monoid: monoid<a>
): <read<h>,write<h>,div,exn|e> ()
  val k' = k + seg.leaf-count
  seg.prod.modify fn(prod)
    prod[k'] := f(prod[k'])
  seg.recalc(k')

// Return the product from the `left`-th element (inclusive) to `right`-th element (exclusive).
// The first element is at position 0 (0-based).
pub fun product(seg: segtree<h,a>, left: int, right: int, ?monoid: monoid<a>): <read<h>,div,exn> a
  fun loop(l: int, r: int, pl, pr)
    if l < r then
      val (l', pl') =
        if l % 2 > 0 then
          (l + 1, (?monoid.mul)(pl, (!seg.prod)[l]))
        else
          (l, pl)
      val (r', pr') =
        if r % 2 > 0 then
          (r - 1, (?monoid.mul)((!seg.prod)[r - 1], pr))
        else
          (r, pr)
      loop(l' / 2, r' / 2, pl', pr')
    else
      (?monoid.mul)(pl, pr)
  loop(
    left + seg.leaf-count,
    right + seg.leaf-count,
    ?monoid.one,
    ?monoid.one
  )

// Return the smallest integer `k` between `start` (inclusive) and `end` (exclusive)
// such that the product from the `start`-th element (inclusive) to the `k`-th
// element (inclusive) holds `p`. If no such `k` exists, return `end`.
// The first element is at position 0 (0-based).
// `p` must be increasing.
pub fun binsearch(
  seg: segtree<h,a>,
  start: int,
  end: int,
  p: forall<h1> a -> <pure,read<h1>|e> bool,
  ?monoid: monoid<a>
): <pure,read<h>|e> int
  fun extend(rs: list<int>, pl)
    match rs
      Nil -> (end + seg.leaf-count, pl)
      Cons(r, rs') ->
        val pl' = (?monoid.mul)(pl, (!seg.prod)[r])
        if p(pl') then (r, pl) else extend(rs', pl')
  fun big-step(l: int, r: int, rs: list<int>, pl)
    if r <= l then return extend(rs, pl)
    val l' = (l + 1) / 2
    val r' = r / 2
    val rs' = if r % 2 == 1 then Cons(r - 1, rs) else rs
    val pl' = if l % 2 == 1 then (?monoid.mul)(pl, (!seg.prod)[l]) else pl
    if l % 2 == 1 && p(pl') then return (l, pl)
    big-step(l'.pretend-decreasing, r', rs', pl')
  fun small-step(i: int, pl)
    if i >= seg.leaf-count then
      i
    else
      val pl' = (?monoid.mul)(pl, (!seg.prod)[i * 2])
      if p(pl') then
        small-step(i * 2, pl)
      else
        small-step(i * 2 + 1, pl')
  val (bi, pl) = big-step(start + seg.leaf-count, end + seg.leaf-count, [], ?monoid.one)
  val si = if bi < end + seg.leaf-count then small-step(bi, pl) else bi
  si - seg.leaf-count

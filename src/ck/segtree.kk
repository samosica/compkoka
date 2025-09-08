/* Segment tree

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

// TODO: fix binsearch
// Return the largest integer `k` such that the product from the first element
// (inclusive) to the `k`-th element (exclusive) holds `p`.
// The first element is at position 0 (0-based).
// `p` must be decreasing and the product of the empty interval must hold `p`.
pub fun binsearch(
  seg: segtree<h,a>,
  p: forall<h1> a -> <read<h1>,div,exn|e> bool,
  ?monoid: monoid<a>
): <read<h>,div,exn|e> int
  fun loop(k, i, v, w)
    if w == 1 then return i
    val v' = (!seg.prod)[k * 2]
    if p((?monoid.mul)(v, v')) then
      loop(k * 2, i, v, w / 2)
    else
      loop(k * 2 + 1, i + w / 2, (?monoid.mul)(v, v'), w / 2)
  loop(1, 0, ?monoid.one, seg.leaf-count)

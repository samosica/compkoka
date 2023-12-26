/* Segment tree

Usage:

```
import segtree

// 1. Define a monoid
fun mon(): monoid<int>
  Monoid(0, (+))

fun main()
  // 2. Create a segment tree
  val t = segtree(10, mon())

  // 3. Manipulate it (see below)
  t.set(1, 3)
  t.set(3, 8)
  t.product(0, 10).println // 11
```
\/
*/
module segtree

pub struct monoid<a>
  one : a
  mul : (a, a) -> a

abstract struct segtree<h,a>
  prod : ref<h,vector<a>>
  leaf-count : int
  mon : monoid<a>

// Create a segment tree
pub fun segtree(n: int, mon: monoid<a>): alloc<h> segtree<h,a>
  var leaf-count := 1
  unsafe-no-div {
    while { leaf-count < n } { leaf-count := leaf-count * 2 }
  }
  Segtree(
    ref(vector(leaf-count * 2, mon.one)),
    leaf-count,
    mon
  )

// Get the `k`-th element.
// The first element is at position 0 (0-based).
pub fun [](^seg: segtree<h,a>, ^k: int): <read<h>,div,exn> a
  (!seg.prod)[k + seg.leaf-count]

// TODO: is div removable?
inline fun recalc(seg: segtree<h,a>, k: int): <read<h>,write<h>,div,exn> ()
  seg.prod.modify fn(prod)
    fun loop(i: int)
      if i <= 1 then return ()
      val p = i / 2
      prod[p] := (seg.mon.mul)(prod[p * 2], prod[p * 2 + 1])
      loop(unsafe-decreasing(p))
    loop(k)

// Set a value to an element.
// The first element is at position 0 (0-based).
pub fun set(seg: segtree<h,a>, k: int, v: a): <read<h>,write<h>,div,exn> ()
  val k' = k + seg.leaf-count
  seg.prod.modify fn(prod) { prod[k'] := v }
  seg.recalc(k')

// Apply a function to an element.
// The first element is at position 0 (0-based).
pub fun update(seg: segtree<h,a>, k: int, f: forall<h1> a -> <local<h1>,div,exn|e> a): <read<h>,write<h>,div,exn|e> ()
  // TODO: make the type of `f` simple
  val k' = k + seg.leaf-count
  seg.prod.modify fn(prod)
    prod[k'] := f(prod[k'])
  seg.recalc(k')

// Return the product from the `left`-th element (inclusive) to `right`-th element (exclusive).
// The first element is at position 0 (0-based).
pub fun product(seg: segtree<h,a>, left: int, right: int): <read<h>,div,exn> a
  fun loop(l: int, r: int, pl, pr)
    if l < r then
      val (l', pl') =
        if l % 2 > 0 then
          (l + 1, (seg.mon.mul)(pl, (!seg.prod)[l]))
        else
          (l, pl)
      val (r', pr') =
        if r % 2 > 0 then
          (r - 1, (seg.mon.mul)((!seg.prod)[r - 1], pr))
        else
          (r, pr)
      loop(l' / 2, r' / 2, pl', pr')
    else
      (seg.mon.mul)(pl, pr)
  loop(
    left + seg.leaf-count,
    right + seg.leaf-count,
    seg.mon.one,
    seg.mon.one
  )

// Return the largest integer `k` such that the product from the first element
// (inclusive) to the `k`-th element (exclusive) holds `p`.
// The first element is at position 0 (0-based).
// `p` must be decreasing and the product of the empty interval must hold `p`.
pub fun binsearch(seg: segtree<h,a>, p: forall<h1> a -> <read<h1>,div,exn|e> bool): <read<h>,div,exn|e> int
  // TODO: make the type of `p` simple
  fun loop(k, i, v, w)
    if w == 1 then return i
    val v' = (!seg.prod)[k * 2]
    if p((seg.mon.mul)(v, v')) then
      loop(k * 2, i, v, w / 2)
    else
      loop(k * 2 + 1, i + w / 2, (seg.mon.mul)(v, v'), w / 2)
  loop(1, 0, seg.mon.one, seg.leaf-count)

pub fun int-add-monoid(): monoid<int>
  Monoid(0, (+))

// Fenwick tree
module fenwick

import std/num/int64

abstract struct fenwick<h>
  tree: ref<h,vector<int>>

// Create a Fenwick tree
pub fun fenwick(size: int): alloc<h> fenwick<h>
  Fenwick(ref(vector(size + 1, 0)))

pub fun size(f: fenwick<h>): read<h> int
  (!f.tree).length - 1

// Find the rightmost 1 of the binary representation of `x`.
// Return 0 if `x` = 0.
// `x` must be within [-2^63, 2^63 - 1), the range of 64-bit signed integers.
fun rightmost-one(x: int)
  (x.int64.and(x.negate.int64)).int

// Add a value to an element.
// The first element is at position 1 (1-based).
// Raise an exception if `index` <= 0 or `index` > `f.size`.
pub fun add(f: fenwick<h>, index: int, value: int): <exn,read<h>,write<h>> ()
  val s = f.size
  if index <= 0 || index > s then "out of bounds".throw
  f.tree.modify fn(t)
    // body, body2 をインライン展開すると segmentation fault が発生する (?)
    // また、local<_> を _ に変えると型推論が失敗する (?)
    fun body(): local<_> ()
      var i := index
      unsafe-no-div{
        fun body2(): _ ()
          // s の代わりに f.size を使うと型に read<_> が2回現れてしまう
          while { i <= s }
            val i' = i
            // mask<local> と unsafe-no-exn の順序は入れ替えてはいけない
            mask<local>{ unsafe-no-exn{ t[i'] := t[i'] + value }}
            i := i + i.rightmost-one
        body2()
      }
    body()

// Return the sum from the first element to the `end`-th element (inclusive).
// The first element is at position 1 (1-based).
// For convenience, return 0 if `end` = 0.
// Raise an exception if `end` < 0 or `end` > `f.size`.
pub fun prefix-sum(f: fenwick<h>, end: int): <exn,read<h>> int
  if end < 0 || end > f.size then "out of bounds".throw
  var sum := 0
  var i := end
  unsafe-no-div {
    while { i > 0 }
      sum := sum + (!f.tree)[i]
      i := i - i.rightmost-one
  }
  sum

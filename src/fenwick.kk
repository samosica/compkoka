// Fenwick trees

import std/num/int64

struct fenwick<h>
  tree: ref<h,vector<int>>

fun fenwick(size: int): alloc<h> fenwick<h>
  Fenwick(ref(vector(size + 1, 0)))

fun size(f: fenwick<h>): read<h> int
  (!f.tree).length - 1

fun rightmost-one(x: int)
  (x.int64.and(x.negate.int64)).int

fun add(f: fenwick<h>, key: int, value: int): <exn,read<h>,write<h>> ()
  val s = f.size
  if key <= 0 || key > s then "out of bounds".throw
  f.tree.modify fn(t)
    // body, body2 をインライン展開すると segmentation fault が発生する (?)
    // また、local<_> を _ に変えると型推論が失敗する (?)
    fun body(): local<_> ()
      var k := key
      unsafe-no-div{
        fun body2(): _ ()
          // s の代わりに f.size を使うと型に read<_> が2回現れてしまう
          while { k <= s }
            val k' = k
            // mask<local> と unsafe-no-exn の順序は入れ替えてはいけない
            mask<local>{ unsafe-no-exn{ t[k'] := t[k'] + value }}
            k := k + k.rightmost-one
        body2()
      }
    body()

fun prefix-sum(f: fenwick<h>, end: int): <exn,read<h>> int
  if end < 0 || end > f.size then "out of bounds".throw
  var sum := 0
  var k := end
  unsafe-no-div {
    while { k > 0 }
      sum := sum + (!f.tree)[k]
      k := k - k.rightmost-one
  }
  sum

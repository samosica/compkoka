// Extra functions on vectors
module ck/vector

import std/core/undiv
import std/num/int32
import std/num/random

// Quicksort
pub fun quicksort(v: vector<a>, comp: (a, a) -> order): <pure,ndet> vector<a>
  var sorted := v
  fun swap(i: int, j: int)
    val tmp = sorted[i]
    sorted[i] := sorted[j]
    sorted[j] := tmp
  fun partition(l: int, r: int, i: int, p)
    if l >= r then
      i
    elif p(sorted[l]) then
      swap(i, l)
      partition((l + 1).pretend-decreasing, r, i + 1, p)
    else
      partition((l + 1).pretend-decreasing, r, i, p)
  fun sort-intl(l: int, r: int)
    if r - l <= 1 then return ()
    val pivot-i = srandom-int32-range(l.int32, r.int32).int
    val pivot = sorted[pivot-i]
    swap(l, pivot-i)
    val i = partition(l + 1, r, l, fn(x) { comp(x, pivot).is-lt })
    val j = partition(i + 1, r, i, fn(x) { comp(x, pivot).is-eq })
    sort-intl(l, i)
    sort-intl(j, r)
  sort-intl(0, v.length)
  sorted

// Return a vector whose `k`-th (0-based) element is the length of the longest
// common prefix of `v` and the suffix starting with `v[k]`.
pub fun z-algorithm(v: vector<a>, eq: (a, a) -> bool): exn vector<int>
  val size = v.length
  if size == 0 then return vector(0, 0)

  pretend-no-div {
    var res := vector(size, 0)
    res[0] := size

    var i := 1
    var j := 0
    var k := 0
    while { i < size }
      while { i + j < size && eq(v[j], v[i + j]) }
        j := j + 1
      res[i] := j
      if j == 0 then
        i := i + 1
        return ()
      k := 1
      while { i + k < size && k + res[k] < j }
        res[i + k] := res[k]
        k := k + 1
      i := i + k
      j := j - k

    res
  }

// TODO: test
fun naive-search(v: vector<a>, sub: vector<a>, start: int, eq: (a, a) -> bool): exn maybe<int>
  fun matching(i: int, j: int): exn bool
    if j == sub.length then return True
    val same = eq(v[i + j], sub[j])
    if !same then return False
    matching(i, (j + 1).pretend-decreasing)
  fun loop(i: int): exn maybe<int>
    if i + sub.length > v.length then return Nothing
    if matching(i, 0) then return Just(i)
    loop((i + 1).pretend-decreasing)
  if start < 0 then return Nothing
  loop(start)

// Return the position of the first occurrence of `sub` in `v`.
// The first element is at position 0 (0-based).
// `start` specifies the starting position to search.
pub fun search(v: vector<a>, sub: vector<a>, eq: (a, a) -> bool, start: int = 0): <div,exn> maybe<int>
  // TODO: is div removable?
  // TODO: test
  // this optimisation works fine?
  if sub.length < 16 then return naive-search(v, sub, start, eq)

  if start < 0 || start + sub.length > v.length then return Nothing
  // Note: inline expansion of `create-w` causes an error like
  // `error: ‘iev_xxxx’ undeclared`.
  fun create-w()
    // sub.length >= 16 so sub[0] exists
    var w := vector(sub.length + v.length - start, sub[0])
    for (0, sub.length - 1) fn(i)
      w[i] := sub[i]
    for (start, v.length - 1) fn(i)
      w[sub.length + i - start] := v[i]
    w
  val w = create-w()
  val l = z-algorithm(w, eq)
  fun loop(i: int): exn maybe<int>
    if i + sub.length > v.length then return Nothing
    val found = l[sub.length + i - start] >= sub.length
    if found then return Just(i)
    loop((i + 1).pretend-decreasing)
  loop(start)

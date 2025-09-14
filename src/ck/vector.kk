// Extra functions on vectors
module ck/vector

import std/core/undiv

// Note: `@unsafe-vector` is introduced in Koka v3.1.3.

// Unsafe function.
// This function is an internal function in the standard library.
// See <https://koka-lang.github.io/koka/doc/std_core_vector.html>
inline extern unsafe-vector(n: ssize_t): total vector<a>
  c inline "kk_vector_alloc(#1, kk_box_null(), kk_context())"

// Unsafe function.
// This function is an internal function in the standard library.
// See <https://koka-lang.github.io/koka/doc/std_core_vector.html>
inline extern unsafe-idx(^v: vector<a>, index: ssize_t): total a
  c "kk_vector_at_borrow"

// Unsafe function.
// This function is an internal function in the standard library.
// See <https://koka-lang.github.io/koka/doc/std_core_vector.html>
inline extern unsafe-assign(v: vector<a>, index: ssize_t, value: a): total ()
  c "kk_vector_unsafe_assign"

/// Implementation notes of sort:
/// - The implementation is merge sort.
/// - It is 2 times faster than when we do not use unsafe-* functions.

// Stable sort
pub fun sort(v: vector<a>, ?(<): (a, a) -> <pure|e> bool): <pure|e> vector<a>
  var res := v
  var temp := unsafe-vector((v.length / 2).ssize_t)
  var p := 0
  var l1 := 0
  var l2 := 0

  fun loop(l: int, r: int)
    if r - l <= 1 then
      return ()

    val m = (l + r) / 2
    loop(l.pretend-decreasing, m)
    loop(m.pretend-decreasing, r)

    for(l, m - 1) fn(i)
      temp.unsafe-assign((i - l).ssize_t, res.unsafe-idx(i.ssize_t))

    p := l
    l1 := l
    l2 := m
    while { l1 < m && l2 < r }
      val v1 = temp.unsafe-idx((l1 - l).ssize_t)
      val v2 = res.unsafe-idx(l2.ssize_t)
      if mask<local>{ v2 < v1 } then
        res.unsafe-assign(p.ssize_t, res.unsafe-idx(l2.ssize_t))
        l2 := l2 + 1
      else
        res.unsafe-assign(p.ssize_t, temp.unsafe-idx((l1 - l).ssize_t))
        l1 := l1 + 1
      p := p + 1

    while { l1 < m }
      res.unsafe-assign(p.ssize_t, temp.unsafe-idx((l1 - l).ssize_t))
      l1 := l1 + 1
      p := p + 1

  loop(0, v.length)
  res

// Return a vector whose `k`-th (0-based) element is the length of the longest
// common prefix of `v` and the suffix starting with `v[k]`.
pub fun z-algorithm(v: vector<a>, ?(==): (a, a) -> bool): exn vector<int>
  val size = v.length
  if size == 0 then return vector(0, 0)

  pretend-no-div {
    var res := vector(size, 0)
    res[0] := size

    var i := 1
    var j := 0
    var k := 0
    while { i < size }
      while { i + j < size && v[j] == v[i + j] }
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

fun naive-search(v: vector<a>, sub: vector<a>, start: int, ?(==): (a, a) -> bool): exn maybe<int>
  fun matching(i: int, j: int): exn bool
    if j == sub.length then return True
    if !(v[i + j] == sub[j]) then return False
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
pub fun search(v: vector<a>, sub: vector<a>, start: int = 0, ?(==): (a, a) -> bool): <div,exn> maybe<int>
  // this line improves performance?
  if sub.length < 16 then return naive-search(v, sub, start)

  if start < 0 || start + sub.length > v.length then return Nothing
  // w = sub + v[start:]
  val w = vector-init(
    sub.length + v.length - start,
    fn(i) { if i < sub.length then sub[i] else v[i - sub.length + start] }
  )
  val l = z-algorithm(w)
  fun loop(i: int): exn maybe<int>
    if i + sub.length > v.length then return Nothing
    val found = l[sub.length + i - start] >= sub.length
    if found then return Just(i)
    loop((i + 1).pretend-decreasing)
  loop(start)

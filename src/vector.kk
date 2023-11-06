import std/num/random

fun quicksort(v: vector<a>, comp: (a, a) -> order): <pure,ndet> vector<a>
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
            partition(unsafe-decreasing(l + 1), r, i + 1, p)
        else
            partition(unsafe-decreasing(l + 1), r, i, p)
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

fun z-algorithm(v: vector<a>, eq: (a, a) -> bool): vector<int>
  val size = v.length
  if size == 0 then return vector(0, 0)

  unsafe-no-div {
    unsafe-no-exn {
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
  }

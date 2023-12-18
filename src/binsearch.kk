// Binary search
module binsearch

// Binary search on the interval of integers between `ok` and `ng`.
// If `ng` < `ok`, the result is the smallest integer satisfying `p`.
// Otherwise, the result is the largest integer satisfying `p`.
// `p` must be monotone such that `p(ok)` = `True` and `p(ng)` = `False`.
pub fun binsearch(ok: int, ng: int, p: int -> e bool): e int
    if abs(ok - ng) <= 1 then return ok
    val m = (ok + ng) / 2
    if p(m) then binsearch(m, ng, p)
    else binsearch(ok, m, p)

// Binary search on the interval of float64 between `ok` and `ng`.
// This function returns a number close to the boundary of `p`, which divides
// a set of numbers into two intervals, all numbers in an interval satisfy `p`,
// and all numbers in another one do not.
// `p` must be monotone such that `p(ok)` = `True` and `p(ng)` = `False`.
pub fun binsearch-f64(ok: float64, ng: float64, t: int, p: float64 -> e bool): e float64
    if t <= 0 then return ok
    val m = (ok + ng) * 0.5
    if p(m) then
        binsearch-f64(m, ng, t - 1, p)
    else
        binsearch-f64(ok, m, t - 1, p)

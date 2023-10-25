// Binary search

fun binsearch(ok: int, ng: int, p: int -> e bool): e int
    if abs(ok - ng) <= 1 then return ok
    val m = (ok + ng) / 2
    if p(m) then binsearch(m, ng, p)
    else binsearch(ok, m, p)

fun binsearch-f64(ok: float64, ng: float64, t: int, p: float64 -> e bool): e float64
    if t <= 0 then return ok
    val m = (ok + ng) * 0.5
    if p(m) then
        binsearch-f64(m, ng, t - 1, p)
    else
        binsearch-f64(ok, m, t - 1, p)

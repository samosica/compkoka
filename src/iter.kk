
// Iteration

// Iterate over integers in decreasing order.
// Do nothing if `start` < `end`.
fun forev(start: int, end: int, action: int -> e ()): e ()
  if start >= end then
    action(start)
    forev(start.dec.unsafe-decreasing, end, action)

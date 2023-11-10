
// Iteration

// Iterate over integers in decreasing order.
// If start < end, this function does nothing.
fun forev(start: int, end: int, action: int -> e ()): e ()
  if start >= end then
    action(start)
    forev(start.dec.unsafe-decreasing, end, action)

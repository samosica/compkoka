// Iteration
module ck/iter

import std/core/undiv

// Iterate over integers in decreasing order.
// Do nothing if `start` < `end`.
pub fun forev(start: int, end: int, action: int -> e ()): e ()
  if start >= end then
    action(start)
    forev(start.dec.pretend-decreasing, end, action)

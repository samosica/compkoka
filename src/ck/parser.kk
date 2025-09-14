// Parser functions
module ck/parser

import std/num/float64

pub inline fun int(s: string): exn int
  s.parse-int.unjust

pub inline fun float64(s: string): exn float64
  s.parse-float64.unjust

pub inline fun string(s: string): string
  s

// Note: in a benchmark, a safe version of char checking the argument was
// 1.82 times slower than the original version.

// Parse a single character.
// N.B. this function does not check whether a given string consist of a single
// character due to performance issue.
pub inline fun char(s: string): exn char
  s.head-char.unjust

pub inline fun list(parse: string -> exn a): ((s: string) -> exn list<a>)
  fn(s) { s.split(" ").map(fn(s') s'.parse) }

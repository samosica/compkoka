// Parser functions
module ck/parser

import std/num/float64

pub inline fun int(s: string): exn int
  s.parse-int.unjust

pub inline fun float64(s: string): exn float64
  s.parse-float64.unjust

pub inline fun string(s: string): string
  s

pub inline fun list(parse: string -> exn a): ((s: string) -> exn list<a>)
  fn(s) { s.split(" ").map(fn(s') s'.parse) }

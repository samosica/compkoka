// Input/Output
module ck/io

import std/os/path
import std/os/file
import std/os/readline

pub fun read-stdin(): <exn,fsys> string
  read-text-file(path("/dev/stdin"))

// Parse integers separated by whitespaces
pub fun parse-ints(s: string): exn list<int>
  s.split(" ").map(fn(s') { s'.parse-int.unjust })

// Read integers from standard input.
// Warning: if a line to be read contains more than 1,022 characters,
// this function does not work properly. Use `read-stdin` and `parse-ints` instead
pub fun read-ints(): <console,exn> list<int>
  readline().parse-ints

pub fun println(l: list<int>, sep: string = " "): console ()
  var first := True
  foreach (l) fn(x)
    if first then first := False
    else sep.print
    x.print
  "".println

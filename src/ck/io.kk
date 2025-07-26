/* Input/Output

A sample code of `stream`:

```
import ck/io

fun main()
  read-stdin().stream
    val a = sint().unjust
    val b = sint().unjust
    val c = sint().unjust
    val s = sstring()
    (a + b + c).print
    " ".print
    s.println
```
\/
*/
module ck/io

import std/os/path
import std/os/file
import std/os/readline

// *Reasonably* fast stream
pub linear effect stream
  fun read-until(p: char -> bool): string
  fun skip-until(p: char -> bool): ()

pub fun skip-whitespaces(): stream ()
  skip-until(is-white)

// Read a string from a stream.
// This function first skips whitespaces, and then reads characters until
// reaching whitespace
pub fun sstring(): stream string
  skip-whitespaces()
  read-until(fn(c) { !c.is-white })

// Read an integer from a stream
pub fun sint(): <div,stream> maybe<int>
  skip-whitespaces()
  sstring().parse-int

pub fun vector/stream(^s: vector<char>, action: () -> <stream,div|e> a): <div|e> a
  var cursor := 0
  with handler
    fun skip-until(p)
      fun loop(): <local<_>,div> ()
        match s.at(cursor)
          Just(c) | p(c) ->
            cursor := cursor + 1
            loop()
          _ -> ()
      loop()
    fun read-until(p)
      fun loop(res): <local<_>,div> string
        match s.at(cursor)
          Just(c) | p(c) ->
            cursor := cursor + 1
            loop(res ++ c.string)
          _ -> res
      loop("")
  action()

pub fun string/stream(^s: string, action: () -> <stream,div|e> a): <div|e> a
  s.vector.stream(action)

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

/* Input/Output

A sample code using `read`:

```
import ck/io

fun main()
  val a = read(int)
  val (b, c) = read(int, int)
  val s = read(string)
  (a + b + c).print
  " ".print
  s.println
```
\/
*/
module ck/io

import std/num/int64
import std/os/path
import std/os/file
import std/os/readline

pub fun read-stdin(): <exn,fsys> string
  read-text-file(path("/dev/stdin"))

/// Implementation notes of `read`:
/// - Parser functions should have type `(s: string) -> exn a` but not
///   `(s: string) -> maybe<a>`. The latter functions are slower than the
///   former ones.

// Read a single value in a line
pub inline fun single/read(
  parse: (s: string) -> exn a
): <console,exn> a
  readline().parse

// Read two values in a line.
// The values must be separated by a single space, and each value except the
// last must not contain spaces.
pub inline fun tuple2/read(
  parse1: (s: string) -> exn a,
  parse2: (s: string) -> exn b
): <console,exn> (a, b)
  match readline().split(" ", 2)
    [s1, s2] -> (s1.parse1, s2.parse2)
    _ -> throw("expect two values")

// Read three values in a line.
// The values must be separated by a single space, and each value except the
// last must not contain spaces.
pub inline fun tuple3/read(
  parse1: (s: string) -> exn a,
  parse2: (s: string) -> exn b,
  parse3: (s: string) -> exn c
): <console,exn> (a, b, c)
  match readline().split(" ", 3)
    [s1, s2, s3] -> (s1.parse1, s2.parse2, s3.parse3)
    _ -> throw("expect three values")

// Read four values in a line.
// The values must be separated by a single space, and each value except the
// last must not contain spaces.
pub inline fun tuple4/read(
  parse1: (s: string) -> exn a,
  parse2: (s: string) -> exn b,
  parse3: (s: string) -> exn c,
  parse4: (s: string) -> exn d
): <console,exn> (a, b, c, d)
  match readline().split(" ", 4)
    [s1, s2, s3, s4] -> (
      s1.parse1,
      s2.parse2,
      s3.parse3,
      s4.parse4
    )
    _ -> throw("expect four values")

// Read five values in a line.
// The values must be separated by a single space, and each value except the
// last must not contain spaces.
pub inline fun tuple5/read(
  parse1: (s: string) -> exn a,
  parse2: (s: string) -> exn b,
  parse3: (s: string) -> exn c,
  parse4: (s: string) -> exn d,
  parse5: (s: string) -> exn e
): <console,exn> (a, b, c, d, e)
  match readline().split(" ", 5)
    [s1, s2, s3, s4, s5] -> (
      s1.parse1,
      s2.parse2,
      s3.parse3,
      s4.parse4,
      s5.parse5
    )
    _ -> throw("expect five values")

extern unsafe/read-int64-internal(i: int64): console int64
  c inline "(scanf(\"%\" SCNd64, &#1), #1)"

// Unsafe: read int64 from the standard input.
// This function is necessary for strict time limits.
pub fun unsafe/read-int64(): console int64
  read-int64-internal(0.int64)

extern unsafe/read-float64-internal(f: float64): console float64
  c inline "(scanf(\"%lf\", &#1), #1)"

// Unsafe: read float64 from the standard input
// This function is necessary for strict time limits.
pub fun unsafe/read-float64(): console float64
  read-float64-internal(0.0)

pub fun println(l: list<int>, sep: string = " "): console ()
  var first := True
  foreach (l) fn(x)
    if first then first := False
    else sep.print
    x.print
  "".println

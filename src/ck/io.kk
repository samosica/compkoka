/* Input/Output

A sample code using this module:

```
import ck/io

fun main()
  val a = read(int)
  val (b, c) = read(int, int)
  val s = read(string)
  println(a + b + c, s)
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

/// Implementation notes of */print:
/// - The implicit parameters are ?print not ?show because show/string/show is
///   chosen for strings in default and it outputs unnecessary double quotes.
/// - The inlined version of default/double/print was faster than the non-inlined
///   version in a benchmark. But for default/triple/print and its successors,
///   inlining made a slight difference in performance. Hence only default/double/print
///   is inlined.

pub inline fun default/double/print(a: a, b: b, ?a/print: a -> console (), ?b/print: b -> console ())
  print(a)
  print(" ")
  print(b)

pub inline fun default/double/println(a: a, b: b, ?a/print: a -> console (), ?b/print: b -> console ())
  print(a, b)
  print("\n")

pub fun default/triple/print(
  a: a, b: b, c: c,
  ?a/print: a -> console (), ?b/print: b -> console (), ?c/print: c -> console ()
)
  print(a)
  print(" ")
  print(b)
  print(" ")
  print(c)

pub fun default/triple/println(
  a: a, b: b, c: c,
  ?a/print: a -> console (), ?b/print: b -> console (), ?c/print: c -> console ()
)
  print(a, b, c)
  print("\n")

pub fun default/quadruple/print(
  a: a, b: b, c: c, d: d,
  ?a/print: a -> console (), ?b/print: b -> console (), ?c/print: c -> console (), ?d/print: d -> console ()
)
  print(a)
  print(" ")
  print(b)
  print(" ")
  print(c)
  print(" ")
  print(d)

pub fun default/quadruple/println(
  a: a, b: b, c: c, d: d,
  ?a/print: a -> console (), ?b/print: b -> console (), ?c/print: c -> console (), ?d/print: d -> console ()
)
  print(a, b, c, d)
  print("\n")

pub fun default/quintuple/print(
  a: a, b: b, c: c, d: d, e: e,
  ?a/print: a -> console (), ?b/print: b -> console (), ?c/print: c -> console (), ?d/print: d -> console (), ?e/print: e -> console ()
)
  print(a)
  print(" ")
  print(b)
  print(" ")
  print(c)
  print(" ")
  print(d)
  print(" ")
  print(e)

pub fun default/quintuple/println(
  a: a, b: b, c: c, d: d, e: e,
  ?a/print: a -> console (), ?b/print: b -> console (), ?c/print: c -> console (), ?d/print: d -> console (), ?e/print: e -> console ()
)
  print(a, b, c, d, e)
  print("\n")

// Print a character.
// Unlike the default print function, this function does not insert quotes.
pub fun char/print(c: char)
  c.string.print

// Print a character with a newline.
// Unlike the default println function, this function does not insert quotes.
pub fun char/println(c: char)
  c.print
  "".println

pub fun list/print(l: list<a>, sep: string = " ", ?print: a -> console ())
  var first := True
  l.foreach fn(x)
    if first then first := False else sep.print
    x.print

pub fun list/println(l: list<a>, sep: string = " ", ?print: a -> console ())
  l.print(sep)
  "".println

pub fun vector/print(v: vector<a>, sep: string = " ", ?print: a -> console ())
  var first := True
  v.foreach fn(x)
    if first then first := False else sep.print
    x.print

pub fun vector/println(v: vector<a>, sep: string = " ", ?print: a -> console ())
  v.print(sep)
  "".println

pub extern flush(): console ()
    c inline "(fflush(stdout))"

module base

import std/os/file
import std/os/path
import std/core/debug

// Print a text to the standard error
fun eprint(text: string): <exn,fsys> ()
  "/dev/stderr".path.write-text-file(text)

// Print a text to the standard error, ending with a new line
fun eprintln(text: string): <exn,fsys> ()
  text.eprint
  "\n".eprint

fun green(action: () -> <exn,fsys> ()): <exn,fsys> ()
  "\x1b[1;32m".eprint
  action()
  "\x1b[0m".eprint

fun red(action: () -> <exn,fsys> ()): <exn,fsys> ()
  "\x1b[1;31m".eprint
  action()
  "\x1b[0m".eprint

// Terminate the program with exit status 1
extern abort(): a ()
  c inline "exit(1)"

pub effect testing
  // Note: we combine `actual` and `expected` into a single parameter so that we reduce
  // the number of parameters. The current implementation of the compiler does not allow
  // operations to take more than four parameter.
  // Note: previous versions of the Koka compiler do not accept operators as parameters
  // of operations, hence we use `eq` instead of `(==)`.
  ctl expect-intl(actual-expected: (a, a), file-line: string, eq: (a, a) -> bool, show: a -> string): ()

pub fun expect(
  actual: a,
  expected: a,
  ?(==): (a, a) -> bool,
  ?show: a -> string,
  // Note: `?kk-file-line` is replaced with the location where `expect` is called,
  // for instance, `main.kk(32)`, in compilation time. This behavior of the compiler
  // is used in std/core/debug, but it is undocumented.
  // Note: previous versions of the Koka compiler do not accept `@implicit/*`.
  ?kk-file-line: string
): <testing,console> ()
  expect-intl((actual, expected), kk-file-line, (==), show)

pub fun test(
  description: string,
  action: () -> <testing,exn,fsys|e> (),
  // Note: `?m/kk-module` is replaced with the name of the module that calls `test`.
  // `m/` is required to avoid a conflict with `debug/file/kk-module`.
  ?m/kk-module: string
): <exn,fsys|e> ()
  ("Testing " ++ description ++ " (in " ++ m/kk-module ++ "): ").eprint
  with handler
    return(_) green { "SUCCEEDED".eprintln }
    ctl expect-intl(actual-expected, file-line, (==), show)
      val (actual, expected) = actual-expected
      if !(actual == expected) then
        red { "FAILED".eprintln }
        eprintln(expected.show ++ " is expected, but the actual value is " ++ actual.show ++ " at " ++ file-line)
        abort()
      else
        resume(())
  action()

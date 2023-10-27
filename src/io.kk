import std/os/path
import std/os/file
import std/os/readline

// reasonably fast stream

linear effect stream
  fun read-until(p: char -> bool): string
  fun skip-until(p: char -> bool): ()

fun skip-whitespaces(): stream ()
  skip-until(is-white)

fun sstring(): stream string
  skip-whitespaces()
  read-until(fn(c) { !c.is-white })

fun sint(): <div,stream> maybe<int>
  skip-whitespaces()
  sstring().parse-int

fun stream(^s: vector<char>, action: () -> <stream,div|e> a): <div|e> a
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

fun stream(^s: string, action: () -> <stream,div|e> a): <div|e> a
  s.vector.stream(action)

fun read-stdin(): <exn,fsys> string
  read-text-file(path("/dev/stdin"))

fun parse-ints(s: string): exn list<int>
  s.split(" ").map(fn(s') { s'.parse-int.unjust })

fun read-ints(): <console,exn> list<int>
  readline().parse-ints

fun println(l: list<int>, sep: string = " "): console ()
  var first := True
  foreach (l) fn(x)
    if first then first := False
    else sep.print
    x.print
  "".println

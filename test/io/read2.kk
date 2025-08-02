import std/num/float64
import ck/io
import ck/parser

fun main()
  val (x, y) = read(int, float64)
  x.println
  y.show-fixed(3).println

import std/num/float64
import ck/io
import ck/parser

fun main()
  val (x, y, z) = read(int, float64, string)
  x.println
  y.show-fixed(3).println
  z.println

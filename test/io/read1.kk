import std/num/float64
import ck/io
import ck/parser

fun main()
  val x = read(int)
  val y = read(float64)
  val z = read(char)
  x.println
  y.show-fixed(3).println
  // string removes unnecessary quotes
  z.string.println

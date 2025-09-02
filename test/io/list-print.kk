import ck/io

fun main()
  // Note: until v3.1.3, the compiler cannot resolve print and println without
  // qualifications.
  ck/io/list/print([1, 2, 3])
  "".println
  ck/io/list/println([4, 5, 6])

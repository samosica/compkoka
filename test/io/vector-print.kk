import ck/io

fun main()
  // Note: until v3.1.3, the compiler cannot resolve print and println without
  // qualifications.
  ck/io/vector/print([1, 2, 3].vector)
  "".println
  ck/io/vector/println([4, 5, 6].vector)

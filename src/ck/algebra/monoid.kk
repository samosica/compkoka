// Monoids
module ck/algebra/monoid

pub value struct monoid<a>
  one: a
  mul: (a, a) -> a

pub val int/add/monoid = Monoid(one = 0, mul = (+))

pub val int/mul/monoid = Monoid(one = 1, mul = (*))

pub val list/app/monoid = Monoid(one = [], mul = (++))

pub fun tuple2/monoid(ma: monoid<a>, mb: monoid<b>): monoid<(a, b)>
  Monoid(
    one = (ma.one, mb.one),
    mul = fn((a1, b1), (a2, b2)) ((ma.mul)(a1, a2), (mb.mul)(b1, b2))
  )

pub fun tuple3/monoid(ma: monoid<a>, mb: monoid<b>, mc: monoid<c>): monoid<(a, b, c)>
  Monoid(
    one = (ma.one, mb.one, mc.one),
    mul = fn((a1, b1, c1), (a2, b2, c2)) ((ma.mul)(a1, a2), (mb.mul)(b1, b2), (mc.mul)(c1, c2))
  )

pub fun tuple4/monoid(ma: monoid<a>, mb: monoid<b>, mc: monoid<c>, md: monoid<d>): monoid<(a, b, c, d)>
  Monoid(
    one = (ma.one, mb.one, mc.one, md.one),
    mul = fn((a1, b1, c1, d1), (a2, b2, c2, d2)) ((ma.mul)(a1, a2), (mb.mul)(b1, b2), (mc.mul)(c1, c2), (md.mul)(d1, d2))
  )

// Note: since version 3.2.0, this function is not chosen as implicit parameters
//       unless you do not pass it explicitly due to the `default` scope. See
//       <https://github.com/koka-lang/koka/blob/70410958f6f828e3e3999b2ea34a59e18f465f94/samples/learn/implicits.kk#L139-L144>.

pub fun default/opposite/monoid(?monoid: monoid<a>): monoid<a>
  Monoid(one = ?monoid.one, mul = fn(x, y) (?monoid.mul)(y, x))

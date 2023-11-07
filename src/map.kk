// TODO: write test

type skewness
  L
  E
  R

type map<b>
  Emp
  Bra{ key: int; value: b; skew: skewness; left: map<b>; right: map<b> }

fun show(s: skewness): string
  match s
    L -> "L"
    E -> "E"
    R -> "R"

fun show(t: map<b>, show': b -> string): string
  match t
    Emp -> "Emp"
    Bra(k, v, s, l, r) ->
      "Bra(" ++ k.show ++ ", " ++ v.show' ++ ", " ++ s.show ++ ", " ++ l.show(show') ++ ", " ++ r.show(show') ++ ")"

fun is-empty(t: map<b>): bool
  match t
    Emp -> True
    _ -> False

fun empty(): map<b>
  Emp

// 左の部分木が 2 だけ高くなっていたら修正する
// 要素の挿入の場合、この関数を呼び出すのは左の部分木に挿入したときだが、
// 要素の削除の場合、「右」の部分木から削除したときであり、逆になるので注意が必要
// 2番目の戻り値が True のとき、修正前後で木の高さは変わらない
fun adjust-l(t: map<b>): (map<b>, bool)
  match t
    Bra(a, x, E, l, r) -> (Bra(a, x, L, l, r), True)
    Bra(a, x, R, l, r) -> (Bra(a, x, E, l, r), False)
    Bra(a, x, L, Bra(b, y, L, l', r'), r) ->
      (Bra(b, y, E, l', Bra(a, x, E, r', r)), False)
    Bra(a, x, L, Bra(b, y, E, l', r'), r) ->
      (Bra(b, y, R, l', Bra(a, x, L, r', r)), True)
    Bra(a, x, L, Bra(b, y, R, l', Bra(c, z, L, l'', r'')), r) ->
      (Bra(c, z, E, Bra(b, y, E, l', l''), Bra(a, x, R, r'', r)), False)
    Bra(a, x, L, Bra(b, y, R, l', Bra(c, z, E, l'', r'')), r) ->
      (Bra(c, z, E, Bra(b, y, E, l', l''), Bra(a, x, E, r'', r)), False)
    Bra(a, x, L, Bra(b, y, R, l', Bra(c, z, R, l'', r'')), r) ->
      (Bra(c, z, E, Bra(b, y, L, l', l''), Bra(a, x, E, r'', r)), False)
    _ -> (t, False) // for exhaustive check

fun adjust-r(t: map<b>): (map<b>, bool)
  match t
    Bra(a, x, L, l, r) -> (Bra(a, x, E, l, r), False)
    Bra(a, x, E, l, r) -> (Bra(a, x, R, l, r), True)
    Bra(a, x, R, l, Bra(b, y, R, l', r')) ->
      (Bra(b, y, E, Bra(a, x, E, l, l'), r'), False)
    Bra(a, x, R, l, Bra(b, y, E, l', r')) ->
      (Bra(b, y, L, Bra(a, x, R, l, l'), r'), True)
    Bra(a, x, R, l, Bra(b, y, L, Bra(c, z, L, l'', r''), r')) ->
      (Bra(c, z, E, Bra(a, x, E, l, l''), Bra(b, y, R, r'', r')), False)
    Bra(a, x, R, l, Bra(b, y, L, Bra(c, z, E, l'', r''), r')) ->
      (Bra(c, z, E, Bra(a, x, E, l, l''), Bra(b, y, E, r'', r')), False)
    Bra(a, x, R, l, Bra(b, y, L, Bra(c, z, R, l'', r''), r')) ->
      (Bra(c, z, E, Bra(a, x, L, l, l''), Bra(b, y, E, r'', r')), False)
    _ -> (t, False) // for exhaustive check

// insert-intl(t, k, v) = (t', grown)
//    t' : t に (k, v) を挿入して得られる木
// grown : 高さが 1 増えたか
fun insert-intl(t: map<b>, k: int, v: b): (map<b>, bool)
  match t
    Emp -> (Bra(k, v, E, Emp, Emp), True)
    Bra(a, _, s, l, r) | k == a ->
      (Bra(a, v, s, l, r), False) // k がすでに存在するときは値を更新する
    Bra(a, x, s, l, r) | k < a ->
      val (l', grown) = l.insert-intl(k, v)
      val t' = Bra(a, x, s, l', r)
      if !grown then return (t', False)
      t'.adjust-l
    Bra(a, x, s, l, r) ->
      val (r', grown) = r.insert-intl(k, v)
      val t' = Bra(a, x, s, l, r')
      if !grown then return (t', False)
      t'.adjust-r

fun insert(t: map<b>, k: int, v: b): map<b>
  t.insert-intl(k, v).fst

fun min-binding(t: map<b>): maybe<(int, b)>
  match t
    Emp -> Nothing
    Bra(a, x, _, Emp, _) -> Just((a, x))
    Bra(_, _, _, l, _) -> l.min-binding

fun max-binding(t: map<b>): maybe<(int, b)>
  match t
    Emp -> Nothing
    Bra(a, x, _, _, Emp) -> Just((a, x))
    Bra(_, _, _, _, r) -> r.max-binding

// erase-intl(t, k) = (t', deleted, shrinked)
//          t' : t から k をなくした木
//     deleted : k を削除したか (元からなければ False)
//    shrinked : 高さが 1 減ったか
fun erase-intl(t: map<b>, k: int): (map<b>, bool, bool)
  match t
    Emp -> (Emp, False, False)
    Bra(a, x, s, l, r) | k < a ->
      val (l', deleted, shrinked) = l.erase-intl(k)
      val t' = Bra(a, x, s, l', r)
      if !shrinked then return (t', deleted, False)
      val (t'', not-shrinked') = t'.adjust-r
      (t'', deleted, !not-shrinked')
    Bra(a, x, s, l, r) | k > a ->
      val (r', deleted, shrinked) = r.erase-intl(k)
      val t' = Bra(a, x, s, l, r')
      if !shrinked then return (t', deleted, False)
      val (t'', not-shrinked') = t'.adjust-l
      (t'', deleted, !not-shrinked')
    Bra(_, _, s, l, r) ->
      match r.min-binding
        Just((mnk, mnv)) ->
          val (r', _, shrinked) = r.erase-intl(mnk)
          val t' = Bra(mnk, mnv, s, l, r')
          if !shrinked then return (t', True, False)
          val (t'', not-shrinked') = t'.adjust-l
          return (t'', True, !not-shrinked')
        _ -> ()
      match l.max-binding
        Just((mxk, mxv)) ->
          val (l', _, shrinked) = l.erase-intl(mxk)
          val t' = Bra(mxk, mxv, s, l', r)
          if !shrinked then return (t', True, False)
          val (t'', not-shrinked') = t'.adjust-r
          return (t'', True, !not-shrinked')
        _ -> ()
      (Emp, True, True)

fun erase(t: map<b>, k: int): map<b>
  t.erase-intl(k).fst

fun erase-with-status(t: map<b>, k: int): (map<b>, bool)
  val (t', deleted, _) = t.erase-intl(k)
  (t', deleted)

fun get(t: map<b>, k: int): maybe<b>
  match t
    Emp -> Nothing
    Bra(a, x, _, _, _) | k == a -> Just(x)
    Bra(a, _, _, l, _) | k < a -> l.get(k)
    Bra(_, _, _, _, r) -> r.get(k)

fun update(t: map<b>, k: int, f: b -> e b): e map<b>
  match t
    Emp -> Emp
    Bra(a, x, s, l, r) | k == a -> Bra(a, f(x), s, l, r)
    Bra(a, x, s, l, r) | k < a -> Bra(a, x, s, l.update(k, f), r)
    Bra(a, x, s, l, r) -> Bra(a, x, s, l, r.update(k, f))

fun update-or-insert(t: map<b>, k: int, f: b -> e b, v: b): e map<b>
  if t.get(k).is-just then
    t.update(k, f)
  else
    t.insert(k, v)

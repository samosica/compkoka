type skewness
  L
  E
  R

type avltree
  Emp
  Bra{ value: int; skew: skewness; left: avltree; right: avltree }

fun show(s: skewness): string
  match s
    L -> "L"
    E -> "E"
    R -> "R"

fun show(t: avltree): string
  match t
    Emp -> "Emp"
    Bra(v, s, l, r) ->
      "Bra(" ++ v.show ++ ", " ++ s.show ++ ", " ++ l.show ++ ", " ++ r.show ++ ")"

fun is-empty(t: avltree): bool
  match t
    Emp -> True
    _ -> False

fun empty(): avltree
  Emp

fun singleton(v: int)
  Bra( value = v, skew = E, left = Emp, right = Emp )

// 左の部分木が 2 だけ高くなっていたら修正する
// 要素の挿入の場合、この関数を呼び出すのは左の部分木に挿入したときだが、
// 要素の削除の場合、「右」の部分木から削除したときであり、逆になるので注意が必要
// 2番目の戻り値が True のとき、修正前後で木の高さは変わらない
fun adjust-l(t: avltree): (avltree, bool)
  match t
    Bra(a, E, l, r) -> (Bra(a, L, l, r), True)
    Bra(a, R, l, r) -> (Bra(a, E, l, r), False)
    Bra(a, L, Bra(b, L, l', r'), r) ->
      (Bra(b, E, l', Bra(a, E, r', r)), False)
    Bra(a, L, Bra(b, E, l', r'), r) ->
      (Bra(b, R, l', Bra(a, L, r', r)), True)
    Bra(a, L, Bra(b, R, l', Bra(c, L, l'', r'')), r) ->
      (Bra(c, E, Bra(b, E, l', l''), Bra(a, R, r'', r)), False)
    Bra(a, L, Bra(b, R, l', Bra(c, E, l'', r'')), r) ->
      (Bra(c, E, Bra(b, E, l', l''), Bra(a, E, r'', r)), False)
    Bra(a, L, Bra(b, R, l', Bra(c, R, l'', r'')), r) ->
      (Bra(c, E, Bra(b, L, l', l''), Bra(a, E, r'', r)), False)
    _ -> (t, False) // for exhaustive check

fun adjust-r(t: avltree): (avltree, bool)
  match t
    Bra(a, L, l, r) -> (Bra(a, E, l, r), False)
    Bra(a, E, l, r) -> (Bra(a, R, l, r), True)
    Bra(a, R, l, Bra(b, R, l', r')) ->
      (Bra(b, E, Bra(a, E, l, l'), r'), False)
    Bra(a, R, l, Bra(b, E, l', r')) ->
      (Bra(b, L, Bra(a, R, l, l'), r'), True)
    Bra(a, R, l, Bra(b, L, Bra(c, L, l'', r''), r')) ->
      (Bra(c, E, Bra(a, E, l, l''), Bra(b, R, r'', r')), False)
    Bra(a, R, l, Bra(b, L, Bra(c, E, l'', r''), r')) ->
      (Bra(c, E, Bra(a, E, l, l''), Bra(b, E, r'', r')), False)
    Bra(a, R, l, Bra(b, L, Bra(c, R, l'', r''), r')) ->
      (Bra(c, E, Bra(a, L, l, l''), Bra(b, E, r'', r')), False)
    _ -> (t, False) // for exhaustive check

// insert-intl(t, v) = (t', grown)
//    t' : t に v を挿入して得られる木
// grown : 高さが 1 増えたか
fun insert-intl(t: avltree, v: int): (avltree, bool)
  match t
    Emp -> (singleton(v), True)
    Bra(a, _, _, _) | v == a -> (t, False) // v がすでに存在するときは追加しない
    Bra(a, s, l, r) | v < a ->
      val (l', grown) = l.insert-intl(v)
      val t' = Bra(a, s, l', r)
      if !grown then return (t', False)
      t'.adjust-l
    Bra(a, s, l, r) ->
      val (r', grown) = r.insert-intl(v)
      val t' = Bra(a, s, l, r')
      if !grown then return (t', False)
      t'.adjust-r

fun insert(t: avltree, v: int): avltree
  t.insert-intl(v).fst

fun min(t: avltree): maybe<int>
  match t
    Emp -> Nothing
    Bra(a, _, Emp, _) -> Just(a)
    Bra(_, _, l, _) -> l.min

fun max(t: avltree): maybe<int>
  match t
    Emp -> Nothing
    Bra(a, _, _, Emp) -> Just(a)
    Bra(_, _, _, r) -> r.max

// erase-intl(t, v) = (t', deleted, shrinked)
//          t' : t から v をなくした木
//     deleted : v を削除したか (元からなければ false)
//    shrinked : 高さが 1 減ったか
fun erase-intl(t: avltree, v: int): (avltree, bool, bool)
  match t
    Emp -> (Emp, False, False)
    Bra(a, s, l, r) | v < a ->
      val (l', deleted, shrinked) = l.erase-intl(v)
      val t' = Bra(a, s, l', r)
      if !shrinked then return (t', deleted, False)
      val (t'', not-shrinked') = t'.adjust-r
      (t'', deleted, !not-shrinked')
    Bra(a, s, l, r) | v > a ->
      val (r', deleted, shrinked) = r.erase-intl(v)
      val t' = Bra(a, s, l, r')
      if !shrinked then return (t', deleted, False)
      val (t'', not-shrinked') = t'.adjust-l
      (t'', deleted, !not-shrinked')
    Bra(_, s, l, r) ->
      match r.min
        Just(mn) ->
          val (r', _, shrinked) = r.erase-intl(mn)
          val t' = Bra(mn, s, l, r')
          if !shrinked then return (t', True, False)
          val (t'', not-shrinked') = t'.adjust-l
          return (t'', True, !not-shrinked')
        _ -> ()
      match l.max
        Just(mx) ->
          val (l', _, shrinked) = l.erase-intl(mx)
          val t' = Bra(mx, s, l', r)
          if !shrinked then return (t', True, False)
          val (t'', not-shrinked') = t'.adjust-r
          return (t'', True, !not-shrinked')
        _ -> ()
      (Emp, True, True)

fun erase(t: avltree, v: int): avltree
  t.erase-intl(v).fst

fun erase-with-status(t: avltree, v: int): (avltree, bool)
  val (t', deleted, _) = t.erase-intl(v)
  (t', deleted)

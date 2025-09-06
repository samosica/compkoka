// Integer set
module ck/set

type skewness
  L
  E
  R

// Sets of integers.
// Duplicates are omitted
abstract type set
  Emp
  Bra{ value: int; skew: skewness; left: set; right: set }

fun skewness/show(s: skewness): string
  match s
    L -> "L"
    E -> "E"
    R -> "R"

pub fun set/show(t: set): string
  match t
    Emp -> "Emp"
    Bra(v, s, l, r) ->
      "Bra(" ++ v.show ++ ", " ++ s.show ++ ", " ++ l.show ++ ", " ++ r.show ++ ")"

// Check whether a set is empty
pub fun is-empty(t: set): bool
  match t
    Emp -> True
    _ -> False

// Create an empty set
pub fun empty(): set
  Emp

// Create a set with a single element
pub fun singleton(v: int)
  Bra( value = v, skew = E, left = Emp, right = Emp )

// Check whether a value belongs to a set
pub fun mem(t: set, v: int): bool
  match t
    Emp -> False
    Bra(a, _, _, _) | v == a -> True
    Bra(a, _, l, _) | v < a -> l.mem(v)
    Bra(_, _, _, r) -> r.mem(v)

// 左の部分木が 2 だけ高くなっていたら修正する
// 要素の挿入の場合、この関数を呼び出すのは左の部分木に挿入したときだが、
// 要素の削除の場合、「右」の部分木から削除したときであり、逆になるので注意が必要
// 2番目の戻り値が True のとき、修正前後で木の高さは変わらない
fun adjust-l(t: set): (set, bool)
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

fun adjust-r(t: set): (set, bool)
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

// add-intl(t, v) = (t', grown)
//    t' : t に v を挿入して得られる木
// grown : 高さが 1 増えたか
fun add-intl(t: set, v: int): (set, bool)
  match t
    Emp -> (singleton(v), True)
    Bra(a, _, _, _) | v == a -> (t, False) // v がすでに存在するときは追加しない
    Bra(a, s, l, r) | v < a ->
      val (l', grown) = l.add-intl(v)
      val t' = Bra(a, s, l', r)
      if !grown then return (t', False)
      t'.adjust-l
    Bra(a, s, l, r) ->
      val (r', grown) = r.add-intl(v)
      val t' = Bra(a, s, l, r')
      if !grown then return (t', False)
      t'.adjust-r

// Add a value to a set.
// Do nothing if the given value already exists
pub fun add(t: set, v: int): set
  t.add-intl(v).fst

// Return the minimum element of a set
pub fun min(t: set): maybe<int>
  match t
    Emp -> Nothing
    Bra(a, _, Emp, _) -> Just(a)
    Bra(_, _, l, _) -> l.min

// Return the maximum element of a set
pub fun max(t: set): maybe<int>
  match t
    Emp -> Nothing
    Bra(a, _, _, Emp) -> Just(a)
    Bra(_, _, _, r) -> r.max

// erase-intl(t, v) = (t', deleted, shrinked)
//          t' : t から v をなくした木
//     deleted : v を削除したか (元からなければ false)
//    shrinked : 高さが 1 減ったか
fun erase-intl(t: set, v: int): (set, bool, bool)
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

// Remove an element from a set.
// Do nothing if the given value does not exist
pub fun erase(t: set, v: int): set
  t.erase-intl(v).fst

// Iterate over elements in ascending order
pub fun foreach(t: set, action: int -> e ()): e ()
  match t
    Emp -> ()
    Bra(v, _, l, r) ->
      foreach(l, action)
      action(v)
      foreach(r, action)

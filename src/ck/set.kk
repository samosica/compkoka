// Integer set
module ck/set

type skewness
  L
  E
  R

// Sets of integers.
// Duplicates are omitted
abstract type set<a>
  Emp
  Bra{ value: a; skew: skewness; left: set<a>; right: set<a> }

fun skewness/show(s: skewness): string
  match s
    L -> "L"
    E -> "E"
    R -> "R"

pub fun set/show(t: set<a>, ?show: a -> string): string
  match t
    Emp -> "Emp"
    Bra(v, s, l, r) ->
      "Bra(" ++ v.show ++ ", " ++ s.show ++ ", " ++ l.show ++ ", " ++ r.show ++ ")"

// Check whether a set is empty
pub fun is-empty(t: set<a>): bool
  match t
    Emp -> True
    _ -> False

// Create an empty set
pub val empty: forall<a> set<a> = Emp

// Create a set with a single element
pub fun singleton(v: a): set<a>
  Bra( value = v, skew = E, left = Emp, right = Emp )

// Check whether a value belongs to a set
pub fun contains(t: set<a>, value: a, ?cmp: (a, a) -> order): bool
  match t
    Emp -> False
    Bra(v, _, _, _) | value == v -> True
    Bra(v, _, l, _) | value < v -> l.contains(value)
    Bra(_, _, _, r) -> r.contains(value)

// 左の部分木が 2 だけ高くなっていたら修正する
// 要素の挿入の場合、この関数を呼び出すのは左の部分木に挿入したときだが、
// 要素の削除の場合、「右」の部分木から削除したときであり、逆になるので注意が必要
// 2番目の戻り値が True のとき、修正前後で木の高さは変わらない
fun adjust-left(t: set<a>): (set<a>, bool)
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

fun adjust-right(t: set<a>): (set<a>, bool)
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
fun add-intl(t: set<a>, value: a, ?cmp: (a, a) -> order): (set<a>, bool)
  match t
    Emp -> (singleton(value), True)
    Bra(v, _, _, _) | value == v -> (t, False) // v がすでに存在するときは追加しない
    Bra(v, s, l, r) | value < v ->
      val (l', grown) = l.add-intl(value)
      val t' = Bra(v, s, l', r)
      if !grown then return (t', False)
      t'.adjust-left
    Bra(v, s, l, r) ->
      val (r', grown) = r.add-intl(value)
      val t' = Bra(v, s, l, r')
      if !grown then return (t', False)
      t'.adjust-right

// Add a value to a set.
// Do nothing if the given value already exists
pub fun add(t: set<a>, value: a, ?cmp: (a, a) -> order): set<a>
  t.add-intl(value).fst

// Return the minimum element of a set
pub fun min(t: set<a>): maybe<a>
  match t
    Emp -> Nothing
    Bra(v, _, Emp, _) -> Just(v)
    Bra(_, _, l, _) -> l.min

// Return the maximum element of a set
pub fun max(t: set<a>): maybe<a>
  match t
    Emp -> Nothing
    Bra(v, _, _, Emp) -> Just(v)
    Bra(_, _, _, r) -> r.max

// remove-intl(t, v) = (t', deleted, shrinked)
//          t' : t から v をなくした木
//     deleted : v を削除したか (元からなければ false)
//    shrinked : 高さが 1 減ったか
fun remove-intl(t: set<a>, value: a, ?cmp: (a, a) -> order): (set<a>, bool, bool)
  match t
    Emp -> (Emp, False, False)
    Bra(v, s, l, r) | value < v ->
      val (l', deleted, shrinked) = l.remove-intl(value)
      val t' = Bra(v, s, l', r)
      if !shrinked then return (t', deleted, False)
      val (t'', not-shrinked') = t'.adjust-right
      (t'', deleted, !not-shrinked')
    Bra(v, s, l, r) | value > v ->
      val (r', deleted, shrinked) = r.remove-intl(value)
      val t' = Bra(v, s, l, r')
      if !shrinked then return (t', deleted, False)
      val (t'', not-shrinked') = t'.adjust-left
      (t'', deleted, !not-shrinked')
    Bra(_, s, l, r) ->
      match r.min
        Just(min-v) ->
          val (r', _, shrinked) = r.remove-intl(min-v)
          val t' = Bra(min-v, s, l, r')
          if !shrinked then return (t', True, False)
          val (t'', not-shrinked') = t'.adjust-left
          return (t'', True, !not-shrinked')
        _ -> ()
      match l.max
        Just(max-v) ->
          val (l', _, shrinked) = l.remove-intl(max-v)
          val t' = Bra(max-v, s, l', r)
          if !shrinked then return (t', True, False)
          val (t'', not-shrinked') = t'.adjust-right
          return (t'', True, !not-shrinked')
        _ -> ()
      (Emp, True, True)

// Remove an element from a set.
// Do nothing if the given value does not exist
pub fun remove(t: set<a>, value: a, ?cmp: (a, a) -> order): set<a>
  t.remove-intl(value).fst

// Iterate over elements in ascending order
pub fun foreach(t: set<a>, action: a -> e ()): e ()
  match t
    Emp -> ()
    Bra(v, _, l, r) ->
      foreach(l, action)
      action(v)
      foreach(r, action)

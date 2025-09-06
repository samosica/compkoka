// Set
module ck/set

type skewness
  L
  E
  R

type tree<a>
  Emp
  Bra{ value: a; skew: skewness; left: tree<a>; right: tree<a> }

// Note: `set<a>` stores the number of key-value pairs, `size'`, in order to
// compute it in constant time, not in logarithmic time.

abstract value struct set<a>
  tree: tree<a>
  size': int

// Return the number of key-value pairs.
// The time complexity is O(1).
pub fun size(s: set<a>): int
  s.size'

fun skewness/show(s: skewness): string
  match s
    L -> "L"
    E -> "E"
    R -> "R"

fun tree/show(t: tree<a>, ?show: a -> string): string
  match t
    Emp -> "Emp"
    Bra(v, s, l, r) ->
      "Bra(" ++ v.show ++ ", " ++ s.show ++ ", " ++ l.show ++ ", " ++ r.show ++ ")"

pub fun set/show(s: set<a>, ?show: a -> string): string
  s.tree.show

// Check whether a set is empty
pub fun is-empty(s: set<a>): bool
  match s.tree
    Emp -> True
    _ -> False

// Create an empty set
pub val empty: forall<a> set<a> = Set(Emp, 0)

// Create a set with a single element
pub fun singleton(v: a): set<a>
  Set(Bra( value = v, skew = E, left = Emp, right = Emp ), 1)

fun tree/contains(t: tree<a>, value: a, ?cmp: (a, a) -> order): bool
  match t
    Emp -> False
    Bra(v, _, _, _) | value == v -> True
    Bra(v, _, l, _) | value < v -> l.contains(value)
    Bra(_, _, _, r) -> r.contains(value)

// Check whether a value belongs to a set.
// The time complexity is O(log size).
pub fun contains(s: set<a>, value: a, ?cmp: (a, a) -> order): bool
  s.tree.contains(value)

// 左の部分木が 2 だけ高くなっていたら修正する
// 要素の挿入の場合、この関数を呼び出すのは左の部分木に挿入したときだが、
// 要素の削除の場合、「右」の部分木から削除したときであり、逆になるので注意が必要
// 2番目の戻り値が True のとき、修正前後で木の高さは変わらない
fun adjust-left(t: tree<a>): (tree<a>, bool)
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

fun adjust-right(t: tree<a>): (tree<a>, bool)
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

// add-intl(t, v) = (t', grown, added)
//    t' : t に v を挿入して得られる木
// grown : 高さが 1 増えたか
// added : key が追加されたか
fun add-intl(t: tree<a>, value: a, ?cmp: (a, a) -> order): (tree<a>, bool, bool)
  match t
    Emp -> (Bra( value = value, skew = E, left = Emp, right = Emp ), True, True)
    Bra(v, _, _, _) | value == v -> (t, False, False) // v がすでに存在するときは追加しない
    Bra(v, s, l, r) | value < v ->
      val (l', grown, added) = l.add-intl(value)
      val t' = Bra(v, s, l', r)
      if !grown then return (t', False, added)
      val (t'', grown') = t'.adjust-left
      (t'', grown', added)
    Bra(v, s, l, r) ->
      val (r', grown, added) = r.add-intl(value)
      val t' = Bra(v, s, l, r')
      if !grown then return (t', False, added)
      val (t'', grown') = t'.adjust-right
      (t'', grown', added)

// Add a value to a set.
// Do nothing if the given value already exists.
// The time complexity is O(log size).
pub fun add(s: set<a>, value: a, ?cmp: (a, a) -> order): set<a>
  val (t, _, added) = s.tree.add-intl(value)
  Set(t, if added then s.size + 1 else s.size)

fun tree/min(t: tree<a>): maybe<a>
  match t
    Emp -> Nothing
    Bra(v, _, Emp, _) -> Just(v)
    Bra(_, _, l, _) -> l.min

// Return the minimum element of a set.
// The time complexity is O(log size).
pub fun min(s: set<a>): maybe<a>
  s.tree.min

fun tree/max(t: tree<a>): maybe<a>
  match t
    Emp -> Nothing
    Bra(v, _, _, Emp) -> Just(v)
    Bra(_, _, _, r) -> r.max

// Return the maximum element of a set.
// The time complexity is O(log size).
pub fun max(s: set<a>): maybe<a>
  s.tree.max

// remove-intl(t, v) = (t', shrinked, deleted)
//          t' : t から v をなくした木
//    shrinked : 高さが 1 減ったか
//     deleted : v を削除したか (元からなければ false)
fun remove-intl(t: tree<a>, value: a, ?cmp: (a, a) -> order): (tree<a>, bool, bool)
  match t
    Emp -> (Emp, False, False)
    Bra(v, s, l, r) | value < v ->
      val (l', shrinked, deleted) = l.remove-intl(value)
      val t' = Bra(v, s, l', r)
      if !shrinked then return (t', False, deleted)
      val (t'', not-shrinked') = t'.adjust-right
      (t'', !not-shrinked', deleted)
    Bra(v, s, l, r) | value > v ->
      val (r', shrinked, deleted) = r.remove-intl(value)
      val t' = Bra(v, s, l, r')
      if !shrinked then return (t', False, deleted)
      val (t'', not-shrinked') = t'.adjust-left
      (t'', !not-shrinked', deleted)
    Bra(_, s, l, r) ->
      match r.min
        Just(min-v) ->
          val (r', shrinked, _) = r.remove-intl(min-v)
          val t' = Bra(min-v, s, l, r')
          if !shrinked then return (t', False, True)
          val (t'', not-shrinked') = t'.adjust-left
          return (t'', !not-shrinked', True)
        _ -> ()
      match l.max
        Just(max-v) ->
          val (l', shrinked, _) = l.remove-intl(max-v)
          val t' = Bra(max-v, s, l', r)
          if !shrinked then return (t', False, True)
          val (t'', not-shrinked') = t'.adjust-right
          return (t'', !not-shrinked', True)
        _ -> ()
      (Emp, True, True)

// Remove an element from a set.
// Do nothing if the given value does not exist.
// The time complexity is O(log size).
pub fun remove(s: set<a>, value: a, ?cmp: (a, a) -> order): set<a>
  val (t, _, deleted) = s.tree.remove-intl(value)
  Set(t, if deleted then s.size - 1 else s.size)

fun tree/foreach(t: tree<a>, action: a -> e ()): e ()
  match t
    Emp -> ()
    Bra(v, _, l, r) ->
      foreach(l, action)
      action(v)
      foreach(r, action)

// Iterate over elements in ascending order
pub fun foreach(s: set<a>, action: a -> e ()): e ()
  s.tree.foreach(action)

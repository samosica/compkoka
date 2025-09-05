/* Map

Keys are integers and values may have an arbitrary type.
*/
module ck/map

// TODO: write test

type skewness
  L
  E
  R

abstract type tree<v>
  Emp
  Bra{ key: int; value: v; skew: skewness; left: tree<v>; right: tree<v> }

// Note: `map<v>` stores the number of key-value pairs, `size`, in order to
// compute it in constant time, not in logarithmic time.

value struct map<v>
  tree: tree<v>
  // The number of key-value pairs
  pub size: int

fun skewness/show(s: skewness): string
  match s
    L -> "L"
    E -> "E"
    R -> "R"

fun tree/show(t: tree<v>, ?show: v -> string): string
  match t
    Emp -> "Emp"
    Bra(k, v, s, l, r) ->
      "Bra(" ++ k.show ++ ", " ++ v.show ++ ", " ++ s.show ++ ", " ++ l.show ++ ", " ++ r.show ++ ")"

pub fun map/show(m: map<v>, ?show: v -> string): string
  m.tree.show

// Check whether a map is empty.
pub fun is-empty(m: map<v>): bool
  match m.tree
    Emp -> True
    _ -> False

// Create an empty map.
pub val empty: forall<v> map<v> = Map(Emp, 0)

fun tree/contains(t: tree<v>, key: int): bool
  match t
    Emp -> False
    Bra(k, _, _, _, _) | key == k -> True
    Bra(k, _, _, l, _) | key < k -> l.contains(key)
    Bra(_, _, _, _, r) -> r.contains(key)

// Check whether a map contains a key.
// The time complexity is O(log size).
pub fun contains(m: map<v>, key: int): bool
  m.tree.contains(key)

// 左の部分木が 2 だけ高くなっていたら修正する
// 要素の挿入の場合、この関数を呼び出すのは左の部分木に挿入したときだが、
// 要素の削除の場合、「右」の部分木から削除したときであり、逆になるので注意が必要
// 2番目の戻り値が True のとき、修正前後で木の高さは変わらない
fun adjust-left(t: tree<v>): (tree<v>, bool)
  // a, b, c: keys
  // x, y, z: values
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

fun adjust-right(t: tree<v>): (tree<v>, bool)
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

// add-intl(t, key, value) = (t', grown, added)
//    t' : t に (key, value) を挿入して得られる木
// grown : 高さが 1 増えたか
// added : key が追加されたか
fun add-intl(t: tree<v>, key: int, value: v): (tree<v>, bool, bool)
  match t
    Emp -> (Bra(key, value, E, Emp, Emp), True, True)
    Bra(k, _, s, l, r) | key == k ->
      (Bra(k, value, s, l, r), False, False) // key がすでに存在するときは値を更新する
    Bra(k, v, s, l, r) | key < k ->
      val (l', grown, added) = l.add-intl(key, value)
      val t' = Bra(k, v, s, l', r)
      if !grown then return (t', False, added)
      val (t'', grown') = t'.adjust-left
      (t'', grown', added)
    Bra(k, v, s, l, r) ->
      val (r', grown, added) = r.add-intl(key, value)
      val t' = Bra(k, v, s, l, r')
      if !grown then return (t', False, added)
      val (t'', grown') = t'.adjust-right
      (t'', grown', added)

// Add a key-value pair to a map.
// If the given key already exists, update the corresponding value.
// The time complexity is O(log size).
pub fun add(m: map<v>, key: int, value: v): map<v>
  val (t, _, added) = m.tree.add-intl(key, value)
  Map(t, if added then m.size + 1 else m.size)

// update-intl(m, key, f) = (m', grown)
//    m' : key の頂点を更新または追加した m
// grown : 高さが 1 増えたか
// added : key が追加されたか
fun update-intl(t: tree<v>, key: int, f: maybe<v> -> e v): e (tree<v>, bool, bool)
  match t
    Emp ->
      (Bra(key, f(Nothing), E, Emp, Emp), True, True) // key を追加
    Bra(k, v, s, l, r) | key == k ->
      (Bra(k, f(Just(v)), s, l, r), False, False) // key がすでに存在するときは値を更新
    Bra(k, v, s, l, r) | key < k ->
      val (l', grown, added) = l.update-intl(key, f)
      val t' = Bra(k, v, s, l', r)
      if !grown then return (t', False, added)
      val (t'', grown') = t'.adjust-left
      (t'', grown', added)
    Bra(k, v, s, l, r) ->
      val (r', grown, added) = r.update-intl(key, f)
      val t' = Bra(k, v, s, l, r')
      if !grown then return (t', False, added)
      val (t'', grown') = t'.adjust-right
      (t'', grown', added)

// Update the key-value pair of a specified key.
// If `key` already exists, replace the corresponding value `v` with `f(Just(v))`.
// Otherwise, add the pair of `key` and `f(Nothing)`.
// The time complexity is O(log size).
pub fun update(m: map<v>, key: int, f: maybe<v> -> e v): e map<v>
  val (t, _, added) = m.tree.update-intl(key, f)
  Map(t, if added then m.size + 1 else m.size)

fun tree/min-binding(t: tree<v>): maybe<(int, v)>
  match t
    Emp -> Nothing
    Bra(k, v, _, Emp, _) -> Just((k, v))
    Bra(_, _, _, l, _) -> l.min-binding

// Return the key-value pair of the smallest key in a map.
// The time complexity is O(log size).
pub fun min-binding(m: map<v>): maybe<(int, v)>
  m.tree.min-binding

fun tree/max-binding(t: tree<v>): maybe<(int, v)>
  match t
    Emp -> Nothing
    Bra(k, v, _, _, Emp) -> Just((k, v))
    Bra(_, _, _, _, r) -> r.max-binding

// Return the key-value pair of the largest key in a map.
// The time complexity is O(log size).
pub fun max-binding(m: map<v>): maybe<(int, v)>
  m.tree.max-binding

// remove-intl(t, key) = (t', shrinked, deleted)
//          t' : t から key をなくした木
//    shrinked : 高さが 1 減ったか
//     deleted : key を削除したか (元からなければ False)
fun remove-intl(t: tree<v>, key: int): (tree<v>, bool, bool)
  match t
    Emp -> (Emp, False, False)
    Bra(k, v, s, l, r) | key < k ->
      val (l', shrinked, deleted) = l.remove-intl(key)
      val m' = Bra(k, v, s, l', r)
      if !shrinked then return (m', False, deleted)
      val (m'', not-shrinked') = m'.adjust-right
      (m'', !not-shrinked', deleted)
    Bra(k, v, s, l, r) | key > k ->
      val (r', shrinked, deleted) = r.remove-intl(key)
      val m' = Bra(k, v, s, l, r')
      if !shrinked then return (m', False, deleted)
      val (m'', not-shrinked') = m'.adjust-left
      (m'', !not-shrinked', deleted)
    Bra(_, _, s, l, r) ->
      match r.min-binding
        Just((min-k, min-v)) ->
          val (r', shrinked, _) = r.remove-intl(min-k)
          val m' = Bra(min-k, min-v, s, l, r')
          if !shrinked then return (m', False, True)
          val (m'', not-shrinked') = m'.adjust-left
          return (m'', !not-shrinked', True)
        _ -> ()
      match l.max-binding
        Just((max-k, max-v)) ->
          val (l', shrinked, _) = l.remove-intl(max-k)
          val m' = Bra(max-k, max-v, s, l', r)
          if !shrinked then return (m', False, True)
          val (m'', not-shrinked') = m'.adjust-right
          return (m'', !not-shrinked', True)
        _ -> ()
      (Emp, True, True)

// Remove a key and the corresponding value from a map.
// Do nothing if the given key does not exist.
// The time complexity is O(log size).
pub fun remove(m: map<v>, key: int): map<v>
  val (t, _, deleted) = m.tree.remove-intl(key)
  Map(t, if deleted then m.size - 1 else m.size)

fun tree/get(t: tree<v>, key: int): maybe<v>
  match t
    Emp -> Nothing
    Bra(k, v, _, _, _) | key == k -> Just(v)
    Bra(k, _, _, l, _) | key < k -> l.get(key)
    Bra(_, _, _, _, r) -> r.get(key)

// Get the value of a specified key.
// The time complexity is O(log size).
pub fun get(m: map<v>, key: int): maybe<v>
  m.tree.get(key)

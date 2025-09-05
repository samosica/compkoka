/* Map

Keys are integers and values may have an arbitrary type.
*/
module ck/map

// TODO: write test

type skewness
  L
  E
  R

abstract type map<v>
  Emp
  Bra{ key: int; value: v; skew: skewness; left: map<v>; right: map<v> }

fun skewness/show(s: skewness): string
  match s
    L -> "L"
    E -> "E"
    R -> "R"

pub fun map/show(m: map<v>, ?show: v -> string): string
  match m
    Emp -> "Emp"
    Bra(k, v, s, l, r) ->
      "Bra(" ++ k.show ++ ", " ++ v.show ++ ", " ++ s.show ++ ", " ++ l.show ++ ", " ++ r.show ++ ")"

// Check whether a map is empty
pub fun is-empty(m: map<v>): bool
  match m
    Emp -> True
    _ -> False

// Create an empty map.
pub val empty: forall<v> map<v> = Emp

// Check whether a map contains a key
pub fun contains(m: map<v>, key: int): bool
  match m
    Emp -> False
    Bra(k, _, _, _, _) | key == k -> True
    Bra(k, _, _, l, _) | key < k -> l.contains(key)
    Bra(_, _, _, _, r) -> r.contains(key)

// 左の部分木が 2 だけ高くなっていたら修正する
// 要素の挿入の場合、この関数を呼び出すのは左の部分木に挿入したときだが、
// 要素の削除の場合、「右」の部分木から削除したときであり、逆になるので注意が必要
// 2番目の戻り値が True のとき、修正前後で木の高さは変わらない
fun adjust-l(m: map<v>): (map<v>, bool)
  // a, b, c: keys
  // x, y, z: values
  match m
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
    _ -> (m, False) // for exhaustive check

fun adjust-r(m: map<v>): (map<v>, bool)
  match m
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
    _ -> (m, False) // for exhaustive check

// insert-intl(m, key, value) = (m', grown)
//    m' : m に (key, value) を挿入して得られる木
// grown : 高さが 1 増えたか
fun insert-intl(m: map<v>, key: int, value: v): (map<v>, bool)
  match m
    Emp -> (Bra(key, value, E, Emp, Emp), True)
    Bra(k, _, s, l, r) | key == k ->
      (Bra(k, value, s, l, r), False) // key がすでに存在するときは値を更新する
    Bra(k, v, s, l, r) | key < k ->
      val (l', grown) = l.insert-intl(key, value)
      val m' = Bra(k, v, s, l', r)
      if !grown then return (m', False)
      m'.adjust-l
    Bra(k, v, s, l, r) ->
      val (r', grown) = r.insert-intl(key, value)
      val m' = Bra(k, v, s, l, r')
      if !grown then return (m', False)
      m'.adjust-r

// Add a key-value pair to a map.
// If the given key already exists, update the corresponding value
pub fun insert(m: map<v>, key: int, value: v): map<v>
  m.insert-intl(key, value).fst

// Return the key-value pair of the smallest key in a map
pub fun min-binding(m: map<v>): maybe<(int, v)>
  match m
    Emp -> Nothing
    Bra(k, v, _, Emp, _) -> Just((k, v))
    Bra(_, _, _, l, _) -> l.min-binding

// Return the key-value pair of the largest key in a map
pub fun max-binding(m: map<v>): maybe<(int, v)>
  match m
    Emp -> Nothing
    Bra(k, v, _, _, Emp) -> Just((k, v))
    Bra(_, _, _, _, r) -> r.max-binding

// erase-intl(m, key) = (m', deleted, shrinked)
//          m' : m から key をなくした木
//     deleted : key を削除したか (元からなければ False)
//    shrinked : 高さが 1 減ったか
fun erase-intl(m: map<v>, key: int): (map<v>, bool, bool)
  match m
    Emp -> (Emp, False, False)
    Bra(k, v, s, l, r) | key < k ->
      val (l', deleted, shrinked) = l.erase-intl(key)
      val m' = Bra(k, v, s, l', r)
      if !shrinked then return (m', deleted, False)
      val (m'', not-shrinked') = m'.adjust-r
      (m'', deleted, !not-shrinked')
    Bra(k, v, s, l, r) | key > k ->
      val (r', deleted, shrinked) = r.erase-intl(key)
      val m' = Bra(k, v, s, l, r')
      if !shrinked then return (m', deleted, False)
      val (m'', not-shrinked') = m'.adjust-l
      (m'', deleted, !not-shrinked')
    Bra(_, _, s, l, r) ->
      match r.min-binding
        Just((min-k, min-v)) ->
          val (r', _, shrinked) = r.erase-intl(min-k)
          val m' = Bra(min-k, min-v, s, l, r')
          if !shrinked then return (m', True, False)
          val (m'', not-shrinked') = m'.adjust-l
          return (m'', True, !not-shrinked')
        _ -> ()
      match l.max-binding
        Just((max-k, max-v)) ->
          val (l', _, shrinked) = l.erase-intl(max-k)
          val m' = Bra(max-k, max-v, s, l', r)
          if !shrinked then return (m', True, False)
          val (m'', not-shrinked') = m'.adjust-r
          return (m'', True, !not-shrinked')
        _ -> ()
      (Emp, True, True)

// Remove a key and the corresponding value from a map.
// Do nothing if the given key does not exist
pub fun erase(m: map<v>, key: int): map<v>
  m.erase-intl(key).fst

pub fun erase-with-status(m: map<v>, key: int): (map<v>, bool)
  val (m', deleted, _) = m.erase-intl(key)
  (m', deleted)

// Get the value of a specified key
pub fun get(m: map<v>, key: int): maybe<v>
  match m
    Emp -> Nothing
    Bra(k, v, _, _, _) | key == k -> Just(v)
    Bra(k, _, _, l, _) | key < k -> l.get(key)
    Bra(_, _, _, _, r) -> r.get(key)

// Update the value of a specified key.
// Do nothing if the key does not exist
pub fun update(m: map<v>, key: int, f: v -> e v): e map<v>
  match m
    Emp -> Emp
    Bra(k, v, s, l, r) | key == k -> Bra(k, f(v), s, l, r)
    Bra(k, v, s, l, r) | key < k -> Bra(k, v, s, l.update(key, f), r)
    Bra(k, v, s, l, r) -> Bra(k, v, s, l, r.update(key, f))

pub fun update-or-insert(m: map<v>, key: int, f: v -> e v, value: v): e map<v>
  if m.get(key).is-just then
    m.update(key, f)
  else
    m.insert(key, value)

/* Pairing heap

Reference:

- Chris Okasaki. Purely Functional Data Structures. Cambridge University Press 1999.
*/
module ck/heap

type multiway-tree<a>
  Emp
  Bra{ value: a; sub: list<multiway-tree<a>> }

/// Implementation notes of `pairing-heap`:
/// - The constructor should not take a comparison function as a field because
///   it is too slow. It is better to pass comparison functions or structs with
///   them to the operations as implicit parameters instead.

abstract type pairing-heap<a>
  PairingHeap{ tree: multiway-tree<a> }

// Check whether a heap is empty
pub inline fun is-empty(h: pairing-heap<a>): bool
  match h.tree
    Emp -> True
    _ -> False

// Create an empty heap.
pub inline fun empty(): pairing-heap<a>
  PairingHeap(Emp)

// Create a heap with a single element.
pub inline fun singleton(v: a): pairing-heap<a>
  PairingHeap(Bra(v, []))

fun multiway-tree/meld(t1: multiway-tree<a>, t2: multiway-tree<a>, ?(<): (a, a) -> bool): multiway-tree<a>
  match t1
    Emp -> t2
    Bra(v1, ss1) ->
      match t2
        Emp -> t1
        Bra(v2, ss2) ->
          if v1 < v2 then
            Bra(v1, Cons(t2, ss1))
          else
            Bra(v2, Cons(t1, ss2))

// Combine two heaps.
// Assume they use the same ordering function
pub inline fun meld(h1: pairing-heap<a>, h2: pairing-heap<a>, ?(<): (a, a) -> bool): pairing-heap<a>
  PairingHeap(meld(h1.tree, h2.tree))

inline fun multiway-tree/insert(t: multiway-tree<a>, v: a, ?(<): (a, a) -> bool): multiway-tree<a>
  meld(t, Bra(v, []))

// Add a value to a heap
pub inline fun insert(h: pairing-heap<a>, v: a, ?(<): (a, a) -> bool): pairing-heap<a>
  PairingHeap(h.tree.insert(v))

// Return the minimum element of a heap
pub inline fun min(h: pairing-heap<a>): maybe<a>
  match h.tree
    Emp -> Nothing
    Bra(v, _) -> Just(v)

fun meld-pairs(ts: list<multiway-tree<a>>, ?(<): (a, a) -> bool): multiway-tree<a>
  match ts
    Cons(t1, Cons(t2, ts')) -> meld(meld(t1, t2), ts'.meld-pairs)
    [] -> Emp
    [t] -> t

// Remove the minimum element from a heap.
// Do nothing if the given heap is empty
pub inline fun remove-min(h: pairing-heap<a>, ?(<): (a, a) -> bool): pairing-heap<a>
  match h.tree
    Emp -> h
    Bra(_, ss) -> PairingHeap(ss.meld-pairs)

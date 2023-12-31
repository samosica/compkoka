/* Pairing heap

Reference:

- Chris Okasaki. Purely Functional Data Structures. Cambridge University Press 1999.

Warning: this implementation is slow
*/
module ck/heap

type multiway-tree<a>
  Emp
  Bra{ value: a; sub: list<multiway-tree<a>> }

abstract type pairing-heap<a>
  Heap{ tree: multiway-tree<a>; comp: (a, a) -> order }

// Check whether a heap is empty
pub inline fun is-empty(h: pairing-heap<a>): bool
  match h.tree
    Emp -> True
    _ -> False

// Create an empty heap.
// `comp` determines the order of elements in the heap
pub inline fun empty(comp: (a, a) -> order): pairing-heap<a>
  Heap(Emp, comp)

// Create a heap with a single element.
// `comp` determines the order of elements in the heap
pub inline fun singleton(v: a, comp: (a, a) -> order): pairing-heap<a>
  Heap(Bra(v, []), comp)

fun meld(t1: multiway-tree<a>, t2: multiway-tree<a>, comp: (a, a) -> order): multiway-tree<a>
  match t1
    Emp -> t2
    Bra(v1, ss1) ->
      match t2
        Emp -> t1
        Bra(v2, ss2) ->
          if comp(v1, v2).is-lt then
            Bra(v1, Cons(t2, ss1))
          else
            Bra(v2, Cons(t1, ss2))

// Combine two heaps.
// Assume they use the same ordering function
pub inline fun meld(h1: pairing-heap<a>, h2: pairing-heap<a>): pairing-heap<a>
  Heap(meld(h1.tree, h2.tree, h1.comp), h1.comp)

fun insert(t: multiway-tree<a>, v: a, comp: (a, a) -> order): multiway-tree<a>
  match t
    Bra(a, ss) ->
      if comp(v, a).is-lt then
        Bra(v, [t])
      else
        Bra(a, Cons(Bra(v, []), ss))
    Emp -> Bra(v, [])

// Add a value to a heap
pub inline fun insert(h: pairing-heap<a>, v: a): pairing-heap<a>
  Heap(h.tree.insert(v, h.comp), h.comp)

// Return the minimum element of a heap
pub inline fun min(h: pairing-heap<a>): maybe<a>
  match h.tree
    Emp -> Nothing
    Bra(v, _) -> Just(v)

fun meld-pairs(ts: list<multiway-tree<a>>, comp: (a, a) -> order): multiway-tree<a>
  match ts
    Cons(t1, Cons(t2, ts')) -> meld(meld(t1, t2, comp), ts'.meld-pairs(comp), comp)
    [] -> Emp
    [t] -> t

// Remove the minimum element from a heap.
// Do nothing if the given heap is empty
pub inline fun erase-min(h: pairing-heap<a>): pairing-heap<a>
  match h.tree
    Emp -> h
    Bra(_, ss) -> Heap(ss.meld-pairs(h.comp), h.comp)

import std/sugar


type
  Result*[T, E] = object
    case isOk*: bool
    of true:
      value*: T
    of false:
      error*: E

proc ok*[T, E](value: T): Result[T, E] =
  Result[T, E](isOk: true, value: value)

proc err*[T, E](error: E): Result[T, E] =
  Result[T, E](isOk: false, error: error)


proc map*[T, E, U](r: Result[T, E], f: T -> U): Result[U, E] =
  if r.isOk: 
    f(r.value)
  else:
    r
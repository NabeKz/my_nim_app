import std/random
import std/times
import std/strformat

type Uuid* = distinct string

proc generateUuid*(): Uuid =
  ## Generates a UUID v4 (random) using standard library
  randomize()

  let
    timePart = getTime().toUnix()
    rand1 = rand(0xFFFF)
    rand2 = rand(0xFFFF)
    rand3 = rand(0xFFFF)
    rand4 = rand(0xFFFF)
    rand5 = rand(0xFFFFFFFF)

  let uuidStr = fmt"{timePart:08x}-{rand1:04x}-4{rand2:03x}-8{rand3:03x}-{rand4:04x}{rand5:08x}"
  Uuid(uuidStr)

proc `$`*(uuid: Uuid): string =
  uuid.string

proc `==`*(a, b: Uuid): bool =
  a.string == b.string

proc `!=`*(a, b: Uuid): bool =
  not (a == b)

when isMainModule:
  # Example usage
  let uuid1 = generateUuid()
  let uuid2 = generateUuid()

  echo uuid1

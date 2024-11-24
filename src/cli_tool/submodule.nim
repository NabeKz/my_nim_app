type State = enum
  header
  hyphen
  content


func update_state(state: State): State =
  case state
  of State.header: State.hyphen
  of State.hyphen: State.content
  of State.content: State.content

func ready(state: State): bool = state == State.content


const SIZE = 100

iterator parse*(str: string): string =
  var result = newStringOfCap(SIZE)
  var state = State.header

  for c in str:
    if state.ready and c == '\n':
      yield result
      result = newStringOfCap(SIZE)
    if state.ready and c != '\n':
      result.add c
    if c == '\n':
      state = state.update_state()



when isMainModule:
  let str = """
  |no|name|
  |---|---|
  |a|b|
  |c|d|
  """

  for s in str.parse:
    echo s

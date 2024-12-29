import src/shared/port/http
import src/feature/user/model

type UnValidateForm = ref object
  name: string
  age: int

type PortDto* = ref object of User
  id: int64

generateUnmarshal(UnValidateForm)


template handleRequest*(body: string, model, op: untyped): untyped =
  let form = body.toJson().unmarshal()
  let model = newUser(name = form.name)
  let errors = model.validate()
  if errors.len > 0:
    echo "error"
  else:
    op


when isMainModule:
  let body = """{"name": "a"}"""
  handleRequest body, user:
    echo user.name
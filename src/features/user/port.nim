import src/shared/port/http
import src/features/user/model

type UnValidateForm = ref object
  name: string
  age: int

type PortDto* = ref object of User
  id: int64

generateUnmarshal(UnValidateForm)


template handleRequest*(body: string, model, op: untyped): untyped =
  let form = body.toJson().unmarshal()
  let model = newUser(name = form.name, age = form.age)
  let errors = model.validate()
  if errors.len > 0:
    echo "error"
  else:
    op


when isMainModule:
  import std/unittest

  let body = """{"name": "a", "age": 20}"""
  handleRequest body, user:
    check user.name == "a"
    check user.age == 20